variable "credentials" {
  description = "Name and description of the secret."
  type = object({
    name        = string
    description = string
  })
}

variable "db_username" {
  description = "Database user name."
  type        = string
}

variable "db_password" {
  description = "Database password."
  type        = string
  sensitive   = true
}

variable "db_endpoint" {
  description = "Database endpoint."
  type        = string
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "flask_app_Secret_key" {
  description = "Secret key for the Flask app."
  type        = string
  sensitive   = true
}

variable "env" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}
