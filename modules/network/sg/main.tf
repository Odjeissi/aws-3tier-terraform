# AWS Allow Traffic SG

resource "aws_security_group" "allow_tls_traffic" {
  name        = var.tls_sg_name
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.env}-${var.tls_sg_name}"
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_inbound_traffic" {
  for_each                     = toset(var.allow_tls_traffic.ports)
  security_group_id            = aws_security_group.allow_tls_traffic.id
  referenced_security_group_id = aws_security_group.allow_alb_traffic.id
  from_port                    = each.value
  ip_protocol                  = var.allow_tls_traffic.ip_protocol
  to_port                      = each.value
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh_inbound_traffic" {
  security_group_id = aws_security_group.allow_tls_traffic.id
  cidr_ipv4         = var.allow_ssh_inbound.cidr_ipv4
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_tls_outbound_traffic" {
  security_group_id = aws_security_group.allow_tls_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# AWS DB Traffic SG

resource "aws_security_group" "allow_db_traffic" {
  name        = var.db_sg_name
  description = "Allow db inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.env}-${var.db_sg_name}"
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_inbound_traffic" {
  for_each          = toset(var.allow_db_traffic.ports)
  security_group_id = aws_security_group.allow_db_traffic.id
  cidr_ipv4         = var.allowed_db_cidr
  from_port         = each.value
  ip_protocol       = var.allow_db_traffic.ip_protocol
  to_port           = each.value
}

resource "aws_vpc_security_group_egress_rule" "allow_db_outbound_traffic" {
  security_group_id = aws_security_group.allow_db_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# AWS ALB Traffic SG

resource "aws_security_group" "allow_alb_traffic" {
  name        = var.alb_sg_name
  description = "Allow alb inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.env}-${var.alb_sg_name}"
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_inbound_traffic" {
  for_each          = toset(var.allow_alb_traffic.ports)
  security_group_id = aws_security_group.allow_alb_traffic.id
  cidr_ipv4         = var.allow_alb_traffic.cidr_ipv4
  from_port         = each.value
  ip_protocol       = var.allow_alb_traffic.ip_protocol
  to_port           = each.value
}

resource "aws_vpc_security_group_egress_rule" "allow_alb_outbound_traffic" {
  security_group_id = aws_security_group.allow_alb_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
