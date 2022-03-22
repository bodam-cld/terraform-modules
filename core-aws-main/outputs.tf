output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "deployment_bucket" {
  value = {
    s3_deployment_bucket = aws_s3_bucket.deployment.id
  }
}
