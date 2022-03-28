module "technical_wildcard" {
  source = "../acm"

  domain_name               = "*.${var.technical_domain}"
  subject_alternative_names = [var.technical_domain]
  route53_zone_id           = aws_route53_zone.this.id
}
