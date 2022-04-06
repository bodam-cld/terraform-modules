resource "aws_ecr_repository" "this" {
  name                 = "${var.environment}-${var.service_name}"
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_id
  }
}
