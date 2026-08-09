variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

variable "num_azs" {
  description = "Number of Availability Zones to use"
  type        = number
}

variable "enable_nat" {
  description = "Enable or disable NAT Gateway"
  type        = bool
}
