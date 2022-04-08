variable "service_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alb_security_group_id" {
  type        = string
  description = "ID of the security group of the ALB. It will be allowed to connect to `container_port`"
}

variable "container_name" {
  type        = string
  default     = ""
  description = "Which container should be exposed towards the target group, if not specified defaults to `service_name`"
}

variable "container_port" {
  type        = number
  description = "The port to expose the service on"
}

variable "health_check_path" {
  type        = string
  description = "Health check path that the target group will probe on"
  default     = "/healthz"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "cluster_id" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "log_retention_in_days" {
  type    = number
  default = 30
}

variable "container_definitions" {
  type = list(object({
    name  = string
    image = string
    portMappings = list(object({
      containerPort = number
    })),
    memoryReservation = number,
  }))
  default = [
    {
      name : "nginx",
      image : "public.ecr.aws/bitnami/nginx:1.20",
      portMappings : [
        {
          containerPort : 8080
        }
      ],
      memoryReservation : 32,
      healthcheck : {
        test : ["CMD", "service", "nginx", "status"]
        timeout : 10
      }
    }
  ]
}

variable "task_cpu" {
  description = "Required for Fargate launch type"
  type        = number
  default     = null
}

variable "task_memory" {
  description = "Required for Fargate launch type"
  type        = number
  default     = null
}

variable "listener_rules" {
  type = list(object({
    priority     = number
    listener_arn = string
    conditions = list(object({
      type   = string
      values = list(string)
    }))
  }))
  default = []
}

variable "ecr_image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "The KMS key ARN that is used to encrypt SSM parameters, ECR repository, cloudwatch logs."
}

variable "kms_enable_key_rotation" {
  type        = bool
  default     = false
  description = "Set automatic rotation if `kms_key_arn` is not defined and the module creates its own key. Each version of each key results in extra cost https://aws.amazon.com/kms/pricing/ ."
}
