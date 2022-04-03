resource "aws_security_group" "this" {
  name        = "${var.environment}-${var.service_name}-ecs"
  description = "${var.environment}-${var.service_name} ECS container security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-${var.service_name}-ecs"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_outbound" {
  description       = "All all outbound"
  security_group_id = aws_security_group.this.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_from_alb" {
  description       = "Allow connections from ALB"
  security_group_id = aws_security_group.this.id

  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = var.alb_security_group_id
}
