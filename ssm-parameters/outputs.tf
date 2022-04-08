output "parameter_names" {
  value = toset(concat(
    [for parameter in aws_ssm_parameter.managed_by_tf : parameter.name],
    [for parameter in aws_ssm_parameter.could_be_changed_outside_of_tf : parameter.name]
  ))
}
