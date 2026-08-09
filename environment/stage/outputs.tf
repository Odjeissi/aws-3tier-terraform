# VPC outputs

output "vpc_id" {
  description = "ID of the main VPC"
  value       = module.vpc_main.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc_main.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private subnets used by ECS"
  value       = module.vpc_main.private_1_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private subnets intended for the database"
  value       = module.vpc_main.private_2_subnet_ids
}


# Security group outputs

output "ecs_security_group_id" {
  description = "Security group ID attached to the ECS service"
  value       = module.Security_Group.allow_tls_traffic_id
}

output "alb_security_group_id" {
  description = "Security group ID attached to the application load balancer"
  value       = module.Security_Group.allow_alb_traffic_id
}

output "database_security_group_id" {
  description = "Security group ID intended for the database"
  value       = module.Security_Group.allow_db_traffic_id
}


# Load balancer outputs

output "load_balancer_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.main_lb.lb_dns_name
}

output "load_balancer_zone_id" {
  description = "Canonical hosted zone ID of the load balancer"
  value       = module.main_lb.lb_zone_id
}

output "target_group_arn" {
  description = "ARN of the load balancer target group"
  value       = module.main_lb.target_group_arn
}


# DNS and certificate outputs


output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = module.main_acm.certificate_arn
}


# ECR outputs

output "ecr_repository_url" {
  description = "URL of the ECR repository used by ECS"
  value       = module.main_ecr.repository_url
}


# IAM outputs

output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  value       = module.iam_role.iam_role_arn
}


# ECS outputs
#
# These require matching outputs to exist inside ../../modules/ecs.

# output "ecs_cluster_id" {
#   description = "ID of the ECS cluster"
#   value       = module.main_ecs.cluster_id
# }

# SM outputs

output "secret_arn" {
  value = module.main_secret_manager.secret_arn
}

#DB outputs

output "db_endpoint" {
  value = module.main_db.db_endpoint
}
