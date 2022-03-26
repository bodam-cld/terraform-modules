variable "name" {
  type        = string
  description = "The load balancer name. This will be concatenated to the <environment>, ie <environment>-<name>"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to put the ALB in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids to put the ALB in"
}

variable "environment" {
  type = string
}

variable "certificate_arn" {
  type        = string
  description = "The ARN for the SSL certificate for the HTTPS listener"
}
