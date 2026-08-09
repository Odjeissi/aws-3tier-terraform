# AWS Cluster

resource "aws_ecs_cluster" "my_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name        = "${var.env}-${var.cluster_name}"
    Environment = var.env
  }
}

# AWS cluster_capacity_providers

resource "aws_ecs_cluster_capacity_providers" "compute" {

  cluster_name = aws_ecs_cluster.my_cluster.name

  capacity_providers = var.cluster_capacity_providers.capacity_providers

  default_capacity_provider_strategy {
    weight            = var.cluster_capacity_providers.default_capacity_provider_strategy.weight
    base              = var.cluster_capacity_providers.default_capacity_provider_strategy.base
    capacity_provider = var.cluster_capacity_providers.default_capacity_provider_strategy.capacity_provider
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "my_app_logs"
  tags = {
    Name        = "${var.env}-my_app_logs"
    Environment = var.env
  }
}

# AWS Task Definitions

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.task_definition.name
  network_mode             = var.task_definition.network_mode
  requires_compatibilities = var.task_definition.requires_compatibilities
  cpu                      = var.task_definition.cpu
  memory                   = var.task_definition.memory
  execution_role_arn       = var.execution_role_arn
  #   task_role_arn            = var.task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = var.container_config.name
      image     = var.container_image_uri
      essential = true

      portMappings = [
        {
          containerPort = var.container_config.portMappings.containerPort
          protocol      = var.container_config.portMappings.protocol
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = "${var.secrets_arn}:DATABASE_URL::"
        },
        {
          name      = "SECRET_KEY"
          valueFrom = "${var.secrets_arn}:SECRET_KEY::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }

      }
    }
  ])

  tags = {
    Name        = "${var.env}-${var.task_definition.name}"
    Environment = var.env
  }

}

# AWS ECS Service


resource "aws_ecs_service" "service" {
  name                    = var.ecs_service_config.name
  cluster                 = aws_ecs_cluster.my_cluster.arn
  task_definition         = aws_ecs_task_definition.task_definition.arn
  desired_count           = var.ecs_service_config.desired_count
  enable_ecs_managed_tags = true

  capacity_provider_strategy {
    capacity_provider = var.cluster_capacity_providers.default_capacity_provider_strategy.capacity_provider
    weight            = var.cluster_capacity_providers.default_capacity_provider_strategy.weight
    base              = var.cluster_capacity_providers.default_capacity_provider_strategy.base
  }

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
  }

  load_balancer {
    target_group_arn = var.tg_arn
    container_name   = var.container_config.name
    container_port   = var.container_config.portMappings.containerPort
  }
  force_new_deployment = true

  force_delete = true

  tags = {
    Name        = "${var.env}-${var.ecs_service_config.name}"
    Environment = var.env
  }
}
