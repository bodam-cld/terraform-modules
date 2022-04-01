variable "name" {
  description = "The name of the cluster"
  type        = string
}

variable "enable_container_insights" {
  description = "Enable container insights for more metrics of docker containers (incurs in extra Cloudwatch costs) https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html"
  type        = bool
  default     = false
}
