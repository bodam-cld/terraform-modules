locals {
  resource_name = "${var.project_name}-${var.environment}"
}

## IAM

# inspiration: https://github.com/terraform-aws-modules/terraform-aws-lambda/blob/master/iam.tf

resource "aws_iam_role" "this" {
  name               = "${var.environment}-lambda-${var.service_name}"
  assume_role_policy = data.aws_iam_policy_document.allow_assume_role.json
}

resource "aws_iam_role_policy_attachment" "service_roles" {
  for_each = var.iam_role_policies

  policy_arn = each.value
  role       = aws_iam_role.this.id
}

data "aws_iam_policy_document" "allow_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ssm_parameters_ro" {
  name   = "ssm-parameters_ro"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.ssm_parameters_ro.json
}

data "aws_iam_policy_document" "ssm_parameters_ro" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    #tfsec:ignore:aws-iam-no-policy-wildcards => access below the wildcard is deliberately allowed
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/${var.project_name}/${var.service_name}/*",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/_shared/*"
    ]
  }

  # statement {
  #   effect    = "Allow"
  #   actions   = ["kms:Decrypt"]
  #   resources = ["arn:aws:kms:eu-west-1:${var.account_id}:key/${var.key_id}"]
  # }
}

# SSM

resource "aws_ssm_parameter" "lambda_role" {
  name  = "/${var.environment}/${var.project_name}/${var.service_name}/serverless/lambda-role"
  type  = "String"
  value = aws_iam_role.this.arn
}
