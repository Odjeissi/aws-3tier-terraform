# VPC module

module "vpc_main" {
  source     = "../../modules/network/vpc"
  region     = var.region
  cidr_block = var.cidr_block
  env        = var.env
  num_azs    = var.num_azs
  enable_nat = var.enable_nat
}

# Security Group Module

module "Security_Group" {
  source = "../../modules/network/sg"
  vpc_id = module.vpc_main.vpc_id
  env    = var.env

  tls_sg_name       = var.tls_sg_name
  allow_tls_traffic = var.allow_tls_traffic
  allow_ssh_inbound = var.allow_ssh_inbound

  db_sg_name       = var.db_sg_name
  allow_db_traffic = var.allow_db_traffic
  allowed_db_cidr  = var.cidr_block

  alb_sg_name       = var.alb_sg_name
  allow_alb_traffic = var.allow_alb_traffic
}

# DB Module

module "main_db" {
  source                     = "../../modules/rds"
  env                        = var.env
  db_config                  = var.db_config
  db_credentials             = var.db_credentials
  db_subnet_group_name       = var.db_subnet_group_name
  db_security_group_ids      = [module.Security_Group.allow_db_traffic_id]
  db_subnet_group_subnet_ids = [for subnet_ids in module.vpc_main.private_2_subnet_ids : subnet_ids]
}

# LB Module

module "main_lb" {
  source                = "../../modules/alb"
  env                   = var.env
  load_balancer_config  = var.load_balancer_config
  target_group_config   = var.target_group_config
  vpc_id                = module.vpc_main.vpc_id
  lb_security_group_ids = [module.Security_Group.allow_alb_traffic_id]
  lb_subnet_ids         = [for subnet_ids in module.vpc_main.public_subnet_ids : subnet_ids]
  certificate_arn       = module.main_acm.certificate_arn
}

# Route53 Module

module "route53_public" {
  source        = "../../modules/route53"
  domain_name   = var.domain_name
  dns_record    = var.dns_record
  alias_name    = module.main_lb.lb_dns_name
  alias_zone_id = module.main_lb.lb_zone_id
}


# ACM Module

module "main_acm" {
  source      = "../../modules/acm"
  domain_name = var.domain_name
}

# ECR Module

module "main_ecr" {
  source = "../../modules/ecr"
  repo   = var.repo
  env    = var.env
}

# IAM Role Module

module "iam_role" {
  source             = "../../modules/iam"
  env                = var.env
  role_name          = var.role_name
  assume_role_policy = var.assume_role_policy
  policy_arn         = var.policy_arn
}

# ECS Module

module "main_ecs" {
  source                     = "../../modules/ecs"
  env                        = var.env
  cluster_name               = var.cluster_name
  cluster_capacity_providers = var.cluster_capacity_providers
  task_definition            = var.task_definition
  execution_role_arn         = module.iam_role.iam_role_arn
  container_image_uri        = "${module.main_ecr.repository_url}@sha256:73a9bb322bfd4d0e2c8c2fa5e3a0aaba41d23a3e526924a6f150c516097e8f6c"
  container_config           = var.container_config
  ecs_service_config         = var.ecs_service_config
  subnets                    = [for subnet_ids in module.vpc_main.private_1_subnet_ids : subnet_ids]
  security_groups            = [module.Security_Group.allow_tls_traffic_id]
  tg_arn                     = module.main_lb.target_group_arn
  secrets_arn                = module.main_secret_manager.secret_arn
  depends_on                 = [module.iam_role, module.main_lb]
  region                     = var.region
}

# SM Modules

module "main_secret_manager" {
  source               = "../../modules/sm"
  credentials          = var.credentials
  db_username          = var.db_credentials.username
  db_password          = var.db_credentials.password
  db_endpoint          = module.main_db.db_endpoint
  db_name              = module.main_db.db_name
  flask_app_Secret_key = var.flask_app_Secret_key
  env                  = var.env
}
