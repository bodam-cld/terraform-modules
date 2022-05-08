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

variable "iam_assume_groups" {
  description = "Map of groups which allow assuming the listed roles"
  type        = map(any)
  default = {
    testing-admins = {
      roles = []
    },
    staging-admins = {
      roles = []
    },
    production-admins = {
      roles = []
    },
  }
}

variable "ops_notification_email" {
  description = "the address where basic cloudwatch alarms will be sent to"
  type        = string
}

variable "billing_alarm" {
  type = map(any)
  default = {
    currency          = "EUR"
    monthly_threshold = "100"
  }
}

variable "ci_deployer_role_arns" {
  description = "A list of IAM role ARNs that are allowed to be assumed by the CI deployer user"
  type        = list(string)
  default     = ["arn:aws:iam::*:role/*-deployer"]
}
