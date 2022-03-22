output "aws_iam_user_keys" {
  value = {
    iam_user_arn          = aws_iam_user.serverless.arn
    iam_access_key        = aws_iam_access_key.serverless.id
    iam_secret_access_key = aws_iam_access_key.serverless.secret
  }
  sensitive = true
}
