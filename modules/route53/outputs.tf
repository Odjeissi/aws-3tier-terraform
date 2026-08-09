output "domain_name" {
  value = aws_route53_record.www.name
}

output "dns_zone_id" {
  value = aws_route53_record.www.zone_id
}
