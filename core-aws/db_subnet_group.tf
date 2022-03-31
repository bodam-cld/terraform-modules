resource "aws_db_subnet_group" "default" {
  count      = var.create_db_subnet_groups ? 1 : 0
  name       = "${var.environment}-default"
  subnet_ids = module.vpc.intra_subnets
}

resource "aws_security_group" "default_rds" {
  count       = var.create_db_subnet_groups ? 1 : 0
  name        = "${var.environment}-default-rds"
  description = "${var.environment}-default RDS container security group. Allows connection to instances from inside the VPC."
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.environment}-default-rds"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "default_rds_allow_egress_vpc" {
  count             = var.create_db_subnet_groups ? 1 : 0
  description       = "Allow TCP egress inside the VPC"
  security_group_id = aws_security_group.default_rds[0].id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "tcp"
  cidr_blocks = [module.vpc.vpc_cidr_block]
}

resource "aws_security_group_rule" "default_rds_allow_ingress_vpc" {
  count             = var.create_db_subnet_groups ? 1 : 0
  description       = "Allow TCP ingress inside the VPC"
  security_group_id = aws_security_group.default_rds[0].id

  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "tcp"
  cidr_blocks = [module.vpc.vpc_cidr_block]
}
