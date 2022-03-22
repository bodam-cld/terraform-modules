#tfsec:ignore:aws-s3-enable-versioning => no need to restore data from this
#tfsec:ignore:aws-s3-enable-bucket-logging => should be considered for better auditing
#tfsec:ignore:aws-s3-encryption-customer-key => will do with the managed key for now, better than nothing
resource "aws_s3_bucket" "deployment" {
  bucket = "${local.resource_name}-serverless-deployment"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "deployment" {
  bucket = aws_s3_bucket.deployment.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "deployment" {
  bucket = aws_s3_bucket.deployment.id
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl
  acl = "private"
}

resource "aws_s3_bucket_public_access_block" "deployment" {
  bucket = aws_s3_bucket.deployment.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

resource "aws_ssm_parameter" "deployment_bucket" {
  name  = "/${var.environment}/bodam/deployer/deployment-bucket"
  type  = "String"
  value = aws_s3_bucket.deployment.id
}
