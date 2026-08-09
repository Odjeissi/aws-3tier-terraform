output "repo_name" {
  value = aws_ecr_repository.repo.name
}

output "repo_arn" {
  value = aws_ecr_repository.repo.arn
}

output "repository_url" {
  value = aws_ecr_repository.repo.repository_url
}
