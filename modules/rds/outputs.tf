output "db_arn" {
  value = aws_db_instance.main_db.arn
}

output "db_id" {
  value = aws_db_instance.main_db.id
}

output "db_name" {
  value = aws_db_instance.main_db.db_name
}

output "db_endpoint" {
  value = aws_db_instance.main_db.endpoint
}

output "db_port" {
  value = aws_db_instance.main_db.port
}
