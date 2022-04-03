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

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "If described, SSM is configured to use this key, otherwise a new key is generated"
}

variable "kms_enable_key_rotation" {
  type        = bool
  default     = false
  description = "Set automatic rotation if `kms_key_id` is not defined and the module creates its own key. Each version of each key results in extra cost https://aws.amazon.com/kms/pricing/ ."
}
