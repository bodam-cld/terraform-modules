resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name = "containerInsights"
    #tfsec:ignore:aws-ecs-enable-container-insight => container insights results in extra metrics that costs money, let this decided
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}
