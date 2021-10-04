# IF we chose to issue an ACM certificate for use with the LB https listener, make that happen
resource "aws_acm_certificate" "app" {
  count             = var.issue_acm_certificate ? 1 : 0
  domain_name       = "${var.app_name}.${var.hosted_zone_name}"
  validation_method = "DNS" #
}

resource "aws_route53_record" "acm_validate" {
  for_each = var.issue_acm_certificate ? {
    for dvo in aws_acm_certificate.app[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.this[0].zone_id
}

resource "aws_acm_certificate_validation" "app" {
  count                   = var.issue_acm_certificate ? 1 : 0
  certificate_arn         = aws_acm_certificate.app[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validate : record.fqdn]
}
