output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  value = { for az, subnets in aws_subnet.public : az => subnets.id }
}

output "private_1_subnet_ids" {
  value = { for az, subnets in aws_subnet.private-1 : az => subnets.id }
}

output "private_2_subnet_ids" {
  value = { for az, subnets in aws_subnet.private-2 : az => subnets.id }
}
