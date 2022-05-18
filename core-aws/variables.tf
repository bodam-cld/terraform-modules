variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "main_domain_name" {
  type = string
}

variable "vpc_enable_nat_gateway" {
  type        = bool
  default     = true
  description = <<-EOF
    needed for egress traffic
    to better understand what's going on here see: https://github.com/terraform-aws-modules/terraform-aws-vpc#nat-gateway-scenarios
  EOF
}

variable "vpc_single_nat_gateway" {
  type        = bool
  default     = true
  description = "multiple AZs and subnets can share one if that's acceptable"
}

variable "vpc_nat_gateway_per_az" {
  type        = bool
  default     = false
  description = "if false each subnets gets a separate gateway"
}

variable "iam_trusted_security_account_id" {
  type = string
}

variable "iam_roles_require_mfa" {
  type    = bool
  default = false
}

variable "create_db_subnet_groups" {
  type        = bool
  default     = false
  description = "If true, it will create a default DB subnet group"
}
