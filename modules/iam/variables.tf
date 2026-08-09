variable "env" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role used by ECS tasks for execution."
  type        = string
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
  type        = set(string)
}
