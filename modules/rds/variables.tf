variable "env" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

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

variable "db_security_group_ids" {
  description = "Set of security group IDs to associate with the database."
  type        = set(string)
}

variable "db_subnet_group_subnet_ids" {
  description = "Set of subnet IDs used to create the database subnet group."
  type        = set(string)
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group to associate with the database instance."
  type        = string
}

variable "db_credentials" {
  description = "Credentials used to authenticate with the database."

  type = object({
    username = string
    password = string
  })

  sensitive = true
}
