# create a hosted zone and associated alias record for the load balancer (if desired)
resource "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.hosted_zone_name
}

resource "aws_route53_record" "app_lb" {
  count   = var.create_hosted_zone ? 1 : 0
  zone_id = aws_route53_zone.this[0].zone_id
  name    = "${var.app_name}.${var.hosted_zone_name}"
  type    = "A"
  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
