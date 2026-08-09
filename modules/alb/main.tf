# AWS Load Balancer

resource "aws_lb" "main_lb" {
  name               = var.load_balancer_config.lb_name
  internal           = var.load_balancer_config.internal
  load_balancer_type = var.load_balancer_config.load_balancer_type

  security_groups = var.lb_security_group_ids
  subnets         = var.lb_subnet_ids

  tags = {
    Name        = "${var.env}-${var.load_balancer_config.lb_name}"
    Environment = var.env
  }
}


# AWS Load Balancer Target Group

resource "aws_lb_target_group" "lb_tg" {
  name        = var.target_group_config.tg_name
  target_type = var.target_group_config.target_type

  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name        = "${var.env}-${var.target_group_config.tg_name}"
    Environment = var.env
  }
}


# HTTP Listener

resource "aws_lb_listener" "lb_http_listener" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


# HTTPS Listener

resource "aws_lb_listener" "lb_https_listener" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}
