variable "allocated_storage_gb" {
  type    = number
  default = 20
}

variable "backup_retention_period_days" {
  type    = number
  default = 7
}

variable "db_subnet_group_name" {
  type = string
}

variable "identifier" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs to allow to connect"
}

variable "allow_ingress_from_security_group_ids" {
  type        = list(string)
  default     = []
  description = "If set, the module will create a security group to allow ingress from the given security group ids"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "Optional, must be set if `allow_ingress_from_security_group_ids is set."
}

variable "random_password_length" {
  type    = number
  default = 16
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "parameter_group_family" {
  type = string
}

variable "storage_type" {
  type    = string
  default = "gp2"
}

variable "parameters" {
  description = "A list of DB parameters to add to the created parameter group"
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = []
}

variable "username" {
  type        = string
  default     = null
  description = "The database user name"
}

variable "db_name" {
  type        = string
  default     = null
  description = "The database name to be created."
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "port" {
  type    = number
  default = null
}
