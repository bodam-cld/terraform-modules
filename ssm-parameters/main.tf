locals {
  parameters = defaults(var.parameters, {
    type                = "String"
    ignore_value_change = false
  })

  kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.ssm[0].key_id
  create_key  = var.kms_key_arn == ""

  # Parameters whose values are set outside of terraform
  value_ignored_parameters = { for parameter in local.parameters : parameter.name => parameter if parameter.ignore_value_change }

  # Parameters that are fully managed by terraform
  value_following_parameters = { for parameter in local.parameters : parameter.name => parameter if !parameter.ignore_value_change }
}

resource "aws_ssm_parameter" "managed_by_tf" {
  for_each = local.value_following_parameters

  name  = "/${var.environment}/${var.service_name}/${each.value.name}"
  type  = each.value.type
  value = sensitive(each.value.value)

  key_id = each.value.type == "SecureString" ? local.kms_key_arn : null
}

resource "aws_ssm_parameter" "could_be_changed_outside_of_tf" {
  for_each = local.value_ignored_parameters

  name  = "/${var.environment}/${var.service_name}/${each.value.name}"
  type  = each.value.type
  value = sensitive(each.value.value)

  key_id = each.value.type == "SecureString" ? local.kms_key_arn : null

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_kms_key" "ssm" {
  count = local.create_key ? 1 : 0

  description = "SSM key for ${var.service_name}"
  key_usage   = "ENCRYPT_DECRYPT"
  #tfsec:ignore:aws-kms-auto-rotate-keys => key rotation keeps all previous version of a key and results in additional cost, let this be decided
  enable_key_rotation = var.kms_enable_key_rotation
}
