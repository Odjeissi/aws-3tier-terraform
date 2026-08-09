# VPC Resource

resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr_block

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.env}-main-vpc"
    Environment = var.env
  }
}

# IGW Resource

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name        = "${var.env}-main-igw"
    Environment = var.env
  }
}

# Fech available AZS

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs    = slice(data.aws_availability_zones.available.names, 0, min(var.num_azs, length(data.aws_availability_zones.available.names)))
  az_map = { for idx, az in local.azs : az => idx }
}

# Public subnet Resource

resource "aws_subnet" "public" {
  for_each                = local.az_map
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, each.value)
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.env}-public-${each.key}"
    Environment = var.env
  }
}

# Private subnet Resource

resource "aws_subnet" "private-1" {
  for_each          = local.az_map
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, each.value + var.num_azs)
  availability_zone = each.key

  tags = {
    Name        = "${var.env}-private-1-${each.key}"
    Environment = var.env
  }
}

resource "aws_subnet" "private-2" {
  for_each          = local.az_map
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, each.value + var.num_azs + var.num_azs)
  availability_zone = each.key

  tags = {
    Name        = "${var.env}-private-2-${each.key}"
    Environment = var.env
  }
}

# Public Route Table Resource

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name        = "${var.env}-pub-rt"
    Environment = var.env
  }
}

# Public Route Table Association Resource

resource "aws_route_table_association" "pub-rt-association" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.pub-rt.id
}

# Private Route Table Resource

resource "aws_route_table" "priv-1-rt" {
  for_each = aws_subnet.private-1
  vpc_id   = aws_vpc.main_vpc.id
  dynamic "route" {
    for_each = var.enable_nat ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main_nat[each.key].id
    }
  }

  tags = {
    Name        = "${var.env}-private-1-rt-${each.key}"
    Environment = var.env
  }
}

resource "aws_route_table" "priv-2-rt" {
  for_each = aws_subnet.private-2
  vpc_id   = aws_vpc.main_vpc.id

  dynamic "route" {
    for_each = var.enable_nat ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main_nat[each.key].id
    }
  }

  tags = {
    Name        = "${var.env}-private-2-rt-${each.key}"
    Environment = var.env
  }
}

# Private Route Table Association Resource

resource "aws_route_table_association" "priv-1-rt-association" {
  for_each       = aws_subnet.private-1
  subnet_id      = each.value.id
  route_table_id = aws_route_table.priv-1-rt[each.key].id
}

resource "aws_route_table_association" "priv-2-rt-association" {
  for_each       = aws_subnet.private-2
  subnet_id      = each.value.id
  route_table_id = aws_route_table.priv-2-rt[each.key].id
}

# EIP Resource

resource "aws_eip" "eip" {
  for_each   = var.enable_nat ? aws_subnet.public : {}
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name        = "${var.env}-eip-${each.key}"
    Environment = var.env
  }
}

# Wait 60 seconds after NAT resources are destroyed to allow
# AWS release associated EIPs
# preventing errors during destroy

resource "time_sleep" "wait_after_nat_destroy" {
  for_each = var.enable_nat ? aws_subnet.public : {}

  depends_on = [aws_eip.eip]

  destroy_duration = "90s"
}

# NAT Resource

resource "aws_nat_gateway" "main_nat" {
  for_each      = var.enable_nat ? aws_subnet.public : {}
  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = each.value.id
  tags = {
    Name        = "${var.env}-nat-${each.key}"
    Environment = var.env
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main_igw, time_sleep.wait_after_nat_destroy]
}
