# AWS DB Resource

resource "aws_db_instance" "main_db" {
  identifier                 = var.db_config.identifier
  db_name                    = var.db_config.db_name
  engine                     = var.db_config.engine
  engine_version             = var.db_config.engine_version
  instance_class             = var.db_config.instance_class
  allocated_storage          = var.db_config.allocated_storage
  username                   = var.db_credentials.username
  password                   = var.db_credentials.password
  skip_final_snapshot        = var.db_config.skip_final_snapshot
  db_subnet_group_name       = aws_db_subnet_group.default.name
  multi_az                   = var.db_config.multi_az
  storage_type               = var.db_config.storage_type
  storage_encrypted          = var.db_config.storage_encrypted
  vpc_security_group_ids     = var.db_security_group_ids
  auto_minor_version_upgrade = var.db_config.auto_minor_version_upgrade
  tags = {
    Name        = "${var.env}-${var.db_config.identifier}"
    Environment = var.env
  }
}

# AWS DB Subnet Group Resource

resource "aws_db_subnet_group" "default" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_group_subnet_ids

  tags = {
    Name        = "${var.env}-${var.db_subnet_group_name}"
    Environment = var.env
  }
}
