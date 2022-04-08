output "service_security_group_id" {
  value = aws_security_group.this.id
}

output "task_role_arn" {
  value = aws_iam_role.task_role.arn
}

output "task_execution_role_arn" {
  value = aws_iam_role.task_execution_role.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "kms_key_arn" {
  value = local.kms_key_arn
}
