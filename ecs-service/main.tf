locals {
  container_name        = var.container_name != "" ? var.container_name : var.container_definitions[0].name
  container_definitions = jsonencode([for definition in module.container_definition : definition.json_map_object])

  launch_type = "FARGATE"
  requires_compatibilities = {
    FARGATE : ["FARGATE"]
  }
  network_mode = "awsvpc"
  target_type  = local.network_mode == "awsvpc" ? "ip" : "instance"
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  container_definitions    = local.container_definitions
  network_mode             = local.network_mode
  requires_compatibilities = local.requires_compatibilities[local.launch_type]

  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn

  cpu    = var.task_cpu
  memory = var.task_memory
}

module "container_definition" {
  for_each = { for definition in var.container_definitions : definition.name => definition }

  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_name  = each.value.name
  container_image = each.value.image

  container_cpu    = 128 # 1/8 CPU
  container_memory = 32  # 32MB

  essential                = true
  readonly_root_filesystem = false

  port_mappings = [
    {
      containerPort = var.container_port # When networkMode=awsvpc, the host ports and container ports in port mappings must match.
      hostPort      = var.container_port
      protocol      = "tcp"
    },
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = data.aws_region.current.name
      awslogs-group         = aws_cloudwatch_log_group.this.name
      awslogs-stream-prefix = each.value.name
    }
    secretOptions = []
  }
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  depends_on      = [aws_lb_target_group.this]
  launch_type     = "FARGATE"

  desired_count                      = var.desired_count
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.environment}/${var.service_name}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.kms_key_arn
}
