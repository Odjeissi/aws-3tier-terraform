# AWS SM

resource "aws_secretsmanager_secret" "credential" {
  name                           = var.credentials.name
  description                    = var.credentials.description
  force_overwrite_replica_secret = true
  recovery_window_in_days        = 0
  tags = {
    Name        = "${var.env}-${var.credentials.name}"
    Environment = var.env
  }
}


resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.credential.id
  secret_string = jsonencode({
    DATABASE_URL : "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}/${var.db_name}"
    SECRET_KEY : var.flask_app_Secret_key
  })
}
