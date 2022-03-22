output "aws_route53_technical_domain" {
  value = {
    name    = var.technical_domain
    zone_id = aws_route53_zone.this.id
  }
}

output "route53_zone_name_servers" {
  value = aws_route53_zone.this.name_servers
}

output "deployment_bucket" {
  value = {
    s3_deployment_bucket = aws_s3_bucket.deployment.id
  }
}
