# AWS Scanning

resource "aws_ecr_registry_scanning_configuration" "configuration" {
  scan_type = "BASIC"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

# AWS Repo

resource "aws_ecr_repository" "repo" {
  name                 = var.repo.name
  image_tag_mutability = "MUTABLE"
  force_delete         = var.repo.force_delete
  tags = {
    Name        = "${var.env}-${var.repo.name}"
    Environment = var.env
  }
}
