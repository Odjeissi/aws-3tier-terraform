variable "env" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

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

variable "execution_role_arn" {
  description = "The execution role arn for task definition."
  type        = string
}

# variable "task_role_arn" {
#   description = "The role arn for task definition."
#   type        = string
# }


variable "container_image_uri" {
  description = "ECR image URI for the ECS container."
  type        = string
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

variable "secrets_arn" {
  description = "ARN of the secrets."
  type        = string
  sensitive   = true
}

variable "ecs_service_config" {
  description = "ECS service configuration."
  type = object({
    name          = string
    desired_count = number
  })
}

variable "subnets" {
  description = "The subnets where the cluster will be"
  type        = set(string)
}

variable "security_groups" {
  description = "The sg that will be attached to this service"
  type        = set(string)
}


variable "tg_arn" {
  description = "The alb arn"
  type        = string
}
