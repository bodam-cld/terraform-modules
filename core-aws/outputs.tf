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

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "datastore_subnet_ids" {
  value = module.vpc.intra_subnets
}

output "technical_wildcard_certificate_arn" {
  value = module.technical_wildcard.certificate_arn
}

output "default_db_subnet_group_id" {
  value = var.create_db_subnet_groups ? aws_db_subnet_group.default[0].id : null
}

output "default_db_subnet_group_arn" {
  value = var.create_db_subnet_groups ? aws_db_subnet_group.default[0].arn : null
}

output "iam_assume_groups" {
  description = "to be fed into the iam_assume_groups input variable of the core-aws-main module"
  value = {
    "${var.environment}-admins"     = { roles = [module.iam_assumable_roles.admin_iam_role_arn] },
    "${var.environment}-powerusers" = { roles = [module.iam_assumable_roles.poweruser_iam_role_arn] },
    "${var.environment}-readonly"   = { roles = [module.iam_assumable_roles.readonly_iam_role_arn] },
  }
}
