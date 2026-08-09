# VPC

region = "us-east-1"

cidr_block = "11.0.0.0/16"

env = "stage"

num_azs = 2


enable_nat = true

# SG

tls_sg_name = "allow_tls_traffic"

allow_tls_traffic = {
  ip_protocol = "tcp"
  ports       = [5000]
}

allow_ssh_inbound = {
  cidr_ipv4 = "0.0.0.0/0"
}

db_sg_name = "allow_postgress_traffic"


allow_db_traffic = {
  ip_protocol = "tcp"
  ports       = [5432]
}


alb_sg_name = "allow_alb_traffic"



allow_alb_traffic = {
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  ports       = [80, 443]
}


# DB

db_config = {
  identifier                 = "postgres-db"
  db_name                    = "employees"
  engine                     = "postgres"
  engine_version             = "16.4"
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  skip_final_snapshot        = true
  multi_az                   = false
  storage_type               = "gp3"
  storage_encrypted          = false
  auto_minor_version_upgrade = false
}

db_subnet_group_name = "db-subnet-group"

# LB

load_balancer_config = {
  lb_name            = "project-alb"
  internal           = false
  load_balancer_type = "application"
}



target_group_config = {
  tg_name = "project-tg"
  # either instance or ip
  target_type = "ip"
}



# route53

domain_name = "thecloudguy.live"


dns_record = {
  name = "www."
  type = "A"
}


# ecr

repo = {
  name         = "project/my-app"
  force_delete = true
}


# IAM Role

role_name = "ecsTaskExecutionRole"


assume_role_policy = {
  Action = "sts:AssumeRole"
  Effect = "Allow"
  Principal = {
    Service = "ecs-tasks.amazonaws.com"
  }
}


policy_arn = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"]


# ECS

cluster_name = "mycluster"



cluster_capacity_providers = {
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = {
    base              = 0
    weight            = 100
    capacity_provider = "FARGATE"
  }
}


task_definition = {
  name                     = "mytask"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
}


container_config = {
  name = "my_app"
  portMappings = {
    containerPort = 5000
    protocol      = "tcp"
  }
}

ecs_service_config = {
  name          = "myserviceapp"
  desired_count = 2
}

# SM

credentials = {
  name        = "app_secrets"
  description = "app_secrets"
}
