resource "aws_security_group" "app_lb" {
  name        = "${var.app_name}-lb"
  description = "${var.app_name}-lb"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group_rule" "lb_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_lb.id
}

resource "aws_security_group_rule" "lb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_lb.id
}


# only allow 443 if we issue a cert
resource "aws_security_group_rule" "lb_https" {
  count             = var.issue_acm_certificate ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_lb.id
}

resource "aws_security_group" "app" {
  name        = var.app_name
  description = var.app_name
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group_rule" "app_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "lb_to_app" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_lb.id
  security_group_id        = aws_security_group.app.id
}
