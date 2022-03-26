output "certificate_arn" {
  value = aws_acm_certificate.this.arn
}

output "domain_validation_options" {
  value = local.domain_validation_options
}
