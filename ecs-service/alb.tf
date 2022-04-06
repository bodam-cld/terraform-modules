resource "aws_lb_target_group" "this" {
  name                 = "${var.environment}-${var.service_name}"
  target_type          = local.target_type
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 120

  health_check {
    enabled = true
    path    = var.health_check_path
    port    = "traffic-port"
  }
}

resource "aws_lb_listener_rule" "https" {
  for_each = { for i, rule in var.listener_rules : i => rule }

  listener_arn = each.value.listener_arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  dynamic "condition" {
    for_each = each.value["conditions"]

    content {
      dynamic "host_header" {
        for_each = condition.value.type == "host_header" ? [condition.value.type] : []
        content {
          values = condition.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = condition.value.type == "path_pattern" ? [condition.value.type] : []
        content {
          values = condition.value.values
        }
      }
    }
  }
}
