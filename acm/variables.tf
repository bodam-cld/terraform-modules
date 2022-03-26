variable "domain_name" {
  type        = string
  description = "The main domain name for the certificate."
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Subject alternative names for the certificate."
  default     = []
}

variable "route53_zone_id" {
  type        = string
  description = "The Route53 zone id in which to create the validation DNS records."
  default     = ""
}
