output "key_id" {
  description = "Either the passed in or the newly generated SSM key id"
  value       = local.kms_key_id
}

output "parameter_names" {
  value = toset([
    for parameter in aws_ssm_parameter.parameter : parameter.name
  ])
}
