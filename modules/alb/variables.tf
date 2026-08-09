variable "env" {
  description = "Deployment environment."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC containing the target group."
  type        = string
}

variable "lb_security_group_ids" {
  description = "Security group IDs assigned to the load balancer."
  type        = list(string)
}

variable "lb_subnet_ids" {
  description = "Subnet IDs assigned to the load balancer."
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate used by the HTTPS listener."
  type        = string
}

variable "load_balancer_config" {
  description = "Load balancer configuration."

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
