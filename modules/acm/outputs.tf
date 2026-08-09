output "certificate_id" {
  value = aws_acm_certificate_validation.validation.id
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.validation.certificate_arn
}
