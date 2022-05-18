module "main_wildcard_certificate" {
  source = "../acm"

  domain_name               = "*.${var.main_domain_name}"
  subject_alternative_names = [var.main_domain_name]
  route53_zone_id           = aws_route53_zone.this.zone_id
}
