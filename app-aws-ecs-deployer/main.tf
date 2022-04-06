locals {
  resource_name = "${var.project_name}-${var.environment}"
}

## User, which is allowed to assume the role
resource "aws_iam_user" "ecs" {
  name = "${var.environment}-ecs-deployer"
}

resource "aws_iam_access_key" "ecs" {
  user = aws_iam_user.ecs.name
}

data "aws_iam_policy_document" "assume_ecs_role" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [module.iam_assumable_role.iam_role_arn]
  }
}

resource "aws_iam_user_policy" "assume_ecs_role" {
  user   = aws_iam_user.ecs.name
  name   = "iam-assume-role_ecs-deployer"
  policy = data.aws_iam_policy_document.assume_ecs_role.json
}

## Deployer role
module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.13"

  trusted_role_arns = [
    aws_iam_user.ecs.arn,
    "arn:aws:iam::${var.iam_trusted_security_account_id}:root"
  ]

  create_role = true

  role_name         = "${var.environment}-ecs-deployer"
  role_requires_mfa = false
}

# default IAM limits: 10 policies per role, 10 policies per group, 6144 characters per policy
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-quotas.html#reference_iam-quotas-entities
# might need to use groups instead in some cases to overcome these limits

data "aws_iam_policy_document" "passrole" {
  statement {
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.environment}-ecs-task-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.environment}-ecs-execution-*",
    ]
  }
}

resource "aws_iam_role_policy" "passrole" {
  name   = "passrole"
  role   = module.iam_assumable_role.iam_role_name
  policy = data.aws_iam_policy_document.passrole.json
}

data "aws_iam_policy_document" "ecr_write" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr_write" {
  name   = "ecr_write"
  role   = module.iam_assumable_role.iam_role_name
  policy = data.aws_iam_policy_document.ecr_write.json
}

data "aws_iam_policy_document" "ecs_service_task_write" {
  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_service_task_write" {
  name   = "ecs-service_task_write"
  role   = module.iam_assumable_role.iam_role_name
  policy = data.aws_iam_policy_document.ecs_service_task_write.json
}
