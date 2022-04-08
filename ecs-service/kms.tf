data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group_name}"]
    }

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "this" {
  count = var.kms_key_arn == null ? 1 : 0

  description = "Belongs to ${var.service_name} service"
  key_usage   = "ENCRYPT_DECRYPT"
  policy      = data.aws_iam_policy_document.kms_policy.json

  #tfsec:ignore:aws-kms-auto-rotate-keys => key rotation keeps all previous version of a key and results in additional cost, let this be decided
  enable_key_rotation = var.kms_enable_key_rotation
}
