output "aws_iam_user_keys" {
  value = {
    iam_user_arn          = aws_iam_user.ecs.arn
    iam_access_key        = aws_iam_access_key.ecs.id
    iam_secret_access_key = aws_iam_access_key.ecs.secret
  }
  sensitive = true
}

output "deployer_role_arn" {
  value = module.iam_assumable_role.iam_role_arn
}
