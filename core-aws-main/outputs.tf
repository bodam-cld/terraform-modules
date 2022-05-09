output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "ci_deployer_keys" {
  value = {
    iam_user_arn          = aws_iam_user.ci_deployer.arn
    iam_access_key        = aws_iam_access_key.ci_deployer.id
    iam_secret_access_key = aws_iam_access_key.ci_deployer.secret
  }
  sensitive = true
}
