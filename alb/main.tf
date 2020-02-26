resource "aws_alb" "alb_module" {
  name            = "${var.project}-${var.function}-${var.environment}"
  subnets         = var.public_subnets
  security_groups = [var.alb_security_group_id]

  access_logs {
    bucket  = var.alb_log_bucket
    prefix  = "${var.project}-${var.function}-${var.environment}"
    enabled = true
  }

  tags = merge(
  var.common_tags,
  map("Name", "${var.project}-${var.function}-${var.environment}")
  )
}

# random string to allow alb target group to be deleted and recreated
resource "random_string" "alb_prefix" {
  length  = 4
  upper   = false
  special = false
}

resource "aws_alb_target_group_attachment" "alb_module" {
  target_group_arn = aws_alb_target_group.alb_module.arn
  target_id        = var.target_id
}

resource "aws_alb_target_group" "alb_module" {
  # name cannot be longer than 32 characters
  name     = "${var.project}-${var.function}-${random_string.alb_prefix.result}-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/${var.health_check_path}"
    unhealthy_threshold = "2"
  }

  tags = merge(
  var.common_tags,
  map("Name", "${var.project}-${var.function}-${random_string.alb_prefix.result}-${var.environment}")
  )
}

data "aws_acm_certificate" "alb_module" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

resource "aws_alb_listener" "alb_module" {
  load_balancer_arn = aws_alb.alb_module.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = data.aws_acm_certificate.alb_module.arn

  default_action {
    target_group_arn = aws_alb_target_group.alb_module.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb_module.id
  port              = 80
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
