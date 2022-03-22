variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "default"
}

variable "domain_name" {
  type = string
}

variable "subject_alternative_names" {
  type    = list(any)
  default = []
}

variable "route53_zone_id" {
  type = string
}

variable "apigateway_log_retention_days" {
  type    = number
  default = 30
}
