variable "repo" {
  description = "the name of the repo"
  type = object({
    name         = string
    force_delete = bool
  })
}

variable "env" {
  description = "Deployment environment."
  type        = string
}
