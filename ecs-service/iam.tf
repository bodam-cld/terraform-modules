# Task role
data "aws_iam_policy_document" "assume_role_ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_role" {
  name               = "${var.environment}-ecs-task-${var.service_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs.json
}

# Task execution role
data "aws_iam_policy_document" "task_execution_role" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.this.arn}:*"]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = [aws_ecr_repository.this.arn]
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.environment}-ecs-execution-${var.service_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs.json
}

resource "aws_iam_role_policy" "task_execution_role" {
  name   = "execution-policy"
  role   = aws_iam_role.task_execution_role.name
  policy = data.aws_iam_policy_document.task_execution_role.json
}

data "aws_iam_policy_document" "ssm_and_secrets" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/${var.service_name}/*"]
  }

  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
    ]

    resources = ["arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:/${var.environment}/${var.service_name}/*"]
  }


  statement {
    actions = [
      "kms:Decrypt"
    ]

    resources = [local.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "execution_ssm_and_secrets" {
  name   = "ssm-and-secret-access"
  role   = aws_iam_role.task_execution_role.name
  policy = data.aws_iam_policy_document.ssm_and_secrets.json
}

resource "aws_iam_role_policy" "task_ssm_and_secrets" {
  name   = "ssm-and-secret-access"
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.ssm_and_secrets.json
}
