output "allow_tls_traffic_arn" {
  value = aws_security_group.allow_tls_traffic.arn
}

output "allow_tls_traffic_id" {
  value = aws_security_group.allow_tls_traffic.id
}

output "allow_db_traffic_arn" {
  value = aws_security_group.allow_db_traffic.arn
}

output "allow_db_traffic_id" {
  value = aws_security_group.allow_db_traffic.id
}


output "allow_alb_traffic_arn" {
  value = aws_security_group.allow_alb_traffic.arn
}

output "allow_alb_traffic_id" {
  value = aws_security_group.allow_alb_traffic.id
}
