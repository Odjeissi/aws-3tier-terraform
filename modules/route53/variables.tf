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

variable "alias_name" {
  description = "DNS name of the alias target."
  type        = string
}

variable "alias_zone_id" {
  description = "Hosted zone ID of the alias target."
  type        = string
}
