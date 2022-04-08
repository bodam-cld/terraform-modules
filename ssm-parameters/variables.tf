terraform {
  experiments = [module_variable_optional_attrs]
}

variable "environment" {
  type = string
}

variable "service_name" {
  type = string
}

variable "parameters" {
  type = list(object({
    name                = string
    value               = string
    type                = optional(string)
    ignore_value_change = optional(bool)
  }))

  sensitive = false
}

variable "kms_key_arn" {
  type = string
}
