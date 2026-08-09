# VPC Variables

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


# SG Variables

variable "tls_sg_name" {
  description = "The name of the SG to be created"
  type        = string
}

variable "allow_tls_traffic" {
  description = "Configuration for allowing TLS traffic"
  type = object({
    ip_protocol = string
    ports       = list(string)
  })
}

variable "allow_ssh_inbound" {
  description = "Allow SSH from administrator IP"
  type = object({
    cidr_ipv4 = string
  })
}

variable "db_sg_name" {
  description = "The name of the SG to be created"
  type        = string
}

variable "allow_db_traffic" {
  description = "Configuration for allowing db traffic"
  type = object({
    ip_protocol = string
    ports       = list(string)
  })
}


variable "alb_sg_name" {
  description = "The name of the SG to be created"
  type        = string
}


variable "allow_alb_traffic" {
  description = "Configuration for allowing TLS traffic"
  type = object({
    cidr_ipv4   = string
    ip_protocol = string
    ports       = list(string)
  })
}

# DB Variables

variable "db_config" {
  description = "Configuration settings for the database instance."
  type = object({
    identifier                 = string
    db_name                    = string
    engine                     = string
    engine_version             = string
    instance_class             = string
    allocated_storage          = number
    skip_final_snapshot        = bool
    multi_az                   = bool
    storage_type               = string
    storage_encrypted          = bool
    auto_minor_version_upgrade = bool
  })
}


variable "db_credentials" {
  description = "Credentials used to authenticate with the database."

  type = object({
    username = string
    password = string
  })
  sensitive = true
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group to associate with the database instance."
  type        = string
}

# LB Variables

variable "load_balancer_config" {
  description = "Config for the LB, including its name, whether it is internal, and the type."

  type = object({
    lb_name            = string
    internal           = bool
    load_balancer_type = string
  })
}


variable "target_group_config" {
  description = "Target group configuration."

  type = object({
    tg_name     = string
    target_type = string
  })
}


# route53 variables

variable "domain_name" {
  description = "Route 53 hosted zone domain name."
  type        = string
}

variable "dns_record" {
  description = "DNS record to create in the hosted zone."

  type = object({
    name = string
    type = string
  })
}

# ecr variables

variable "repo" {
  description = "value"
  type = object({
    name         = string
    force_delete = bool
  })
}

# IAM Role variables

variable "role_name" {
  description = "Name of the IAM role used by ECS tasks for execution."

  type = string
}

variable "assume_role_policy" {
  description = "IAM trust policy configuration that allows the specified service principal to assume the role."

  type = object({
    Action = string
    Effect = string
    Principal = object({
      Service = string
    })
  })
}

variable "policy_arn" {
  description = "ARN of the AWS managed IAM policy to attach to the ECS task execution role."

  type = set(string)
}

# ECS variables

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}


variable "cluster_capacity_providers" {
  description = "Configuration for ECS capacity providers and the default capacity provider strategy."

  type = object({
    capacity_providers = set(string)

    default_capacity_provider_strategy = object({
      weight            = number
      base              = number
      capacity_provider = string

    })
  })
}

variable "task_definition" {
  description = "ECS task definition"
  type = object({
    name                     = string
    network_mode             = string
    cpu                      = number
    memory                   = number
    requires_compatibilities = set(string)
  })
}

variable "container_config" {
  description = "ECS container configuration."

  type = object({
    name = string
    portMappings = object({
      containerPort = number
      protocol      = string
    })
  })
}

variable "ecs_service_config" {
  description = "ECS service configuration."
  type = object({
    name          = string
    desired_count = number
  })
}

# SM Variables

variable "credentials" {
  description = "Name and description of the secret."
  type = object({
    name        = string
    description = string
  })
}

variable "flask_app_Secret_key" {
  description = "Secret key for the Flask app."
  type        = string
  sensitive   = true
}
