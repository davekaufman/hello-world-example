resource "aws_lb_target_group" "app" {
  name        = var.app_name
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id

  health_check {
    enabled = true
    path    = "/health"
  }

  tags = merge(
    {
      Name = var.app_name
    },
    var.tags
  )
}

resource "aws_lb" "app" {
  name               = var.app_name
  internal           = false
  load_balancer_type = "application"

  subnets = aws_subnet.public.*.id

  security_groups = [aws_security_group.app_lb.id]

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = var.app_name
    enabled = true
  }

}

# if we issue a cert, redirect 80 to 443
resource "aws_lb_listener" "app_80_redirect" {
  count             = var.issue_acm_certificate ? 1 : 0
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
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

# if we don't issue a cert, don't redirect to 443
resource "aws_lb_listener" "app_80" {
  count             = var.issue_acm_certificate ? 0 : 1
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_listener" "app_443" {
  count             = var.issue_acm_certificate ? 1 : 0
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-2018-06"
  certificate_arn   = aws_acm_certificate.app[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
