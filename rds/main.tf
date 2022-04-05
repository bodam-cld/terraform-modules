locals {
  ports = {
    "mysql"    = 3306
    "postgres" = 5432
  }

  port = coalesce(var.port, local.ports[var.engine])
}

resource "random_password" "password" {
  length           = var.random_password_length
  override_special = "!#$%&*()-_=+[]{}<>:?" # beacuse some characters are not allowed, '@', '"', ' ', '/'
}

resource "aws_db_instance" "this" {
  identifier     = var.identifier
  instance_class = var.instance_class
  engine         = var.engine
  engine_version = var.engine_version

  allocated_storage = var.allocated_storage_gb
  storage_type      = var.storage_type
  storage_encrypted = true

  allow_major_version_upgrade = false
  apply_immediately           = var.apply_immediately
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade

  backup_retention_period = var.backup_retention_period_days
  backup_window           = "02:00-03:00"
  skip_final_snapshot     = var.skip_final_snapshot

  deletion_protection  = var.deletion_protection
  parameter_group_name = aws_db_parameter_group.this.name
  publicly_accessible  = false

  username = var.username
  password = random_password.password.result
  db_name  = var.db_name
  port     = local.port

  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = concat(var.vpc_security_group_ids, aws_security_group.this.*.id)

  lifecycle {
    ignore_changes = [password, latest_restorable_time]
  }
}

resource "aws_db_parameter_group" "this" {
  name_prefix = var.identifier
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "this" {
  count       = length(var.allow_ingress_from_security_group_ids) > 0 ? 1 : 0
  name        = "${var.identifier}-rds"
  description = "${var.identifier} RDS security group."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.identifier}-rds"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this_ingress" {
  for_each = { for id in var.allow_ingress_from_security_group_ids : id => id }

  description       = "Allow ingress from ${each.value}"
  security_group_id = aws_security_group.this[0].id

  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = each.value
}
