locals {
  resource_name = "${var.project_name}-${var.environment}"
}

## IAM

resource "aws_iam_user" "serverless" {
  name = "${var.environment}-serverless-deployer"
}

resource "aws_iam_access_key" "serverless" {
  user = aws_iam_user.serverless.name
}

resource "aws_iam_user_policy" "assume_serverless_role" {
  user = aws_iam_user.serverless.name
  name = "iam-assume-role_serverless-deployer"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "${module.iam_assumable_role.iam_role_arn}"
      }
    }
  EOF
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.13"

  trusted_role_arns = [
    aws_iam_user.serverless.arn,
    "arn:aws:iam::${var.iam_trusted_security_account_id}:root"
  ]

  create_role = true

  role_name         = "${var.environment}-serverless-deployer"
  role_requires_mfa = false
}

# default IAM limits: 10 policies per role, 10 policies per group, 6144 characters per policy
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-quotas.html#reference_iam-quotas-entities
# might need to use groups instead in some cases to overcome these limits

resource "aws_iam_role_policy" "lambda" {
  name = "lambda"
  role = module.iam_assumable_role.iam_role_name

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "cloudformation:DescribeStacks",
                    "cloudformation:ListStackResources",
                    "cloudwatch:ListMetrics",
                    "cloudwatch:GetMetricData",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeVpcs",
                    "kms:ListAliases",
                    "iam:GetPolicy",
                    "iam:GetPolicyVersion",
                    "iam:GetRole",
                    "iam:GetRolePolicy",
                    "iam:ListAttachedRolePolicies",
                    "iam:ListRolePolicies",
                    "iam:ListRoles",
                    "lambda:*",
                    "logs:DescribeLogGroups",
                    "states:DescribeStateMachine",
                    "states:ListStateMachines",
                    "tag:GetResources",
                    "xray:GetTraceSummaries",
                    "xray:BatchGetTraces"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "logs:DescribeLogStreams",
                    "logs:GetLogEvents",
                    "logs:FilterLogEvents"
                ],
                "Resource": "arn:aws:logs:*:*:log-group:/aws/lambda/*"
            }
        ]
    }
  EOF
}

resource "aws_iam_role_policy" "lambda_cloudformation" {
  name = "cloudformation"
  role = module.iam_assumable_role.iam_role_name

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:*"
            ],
            "Resource": "*"
        },
        {
          "Action": [
            "events:*"
          ],
          "Effect": "Allow",
          "Resource": "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/*"
        },
        {
          "Action": [
            "s3:GetBucketLocation",
            "s3:ListBucket"
          ],
          "Effect": "Allow",
          "Resource": "*"
        },
        {
          "Action": [
            "s3:AbortMultipartUpload",
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Effect": "Allow",
          "Resource": "arn:aws:s3:::${local.resource_name}-serverless-deployment/*"
        }
      ]
    }
  EOF

}

resource "aws_iam_role_policy" "lambda_ec2_logs" {
  name = "ec2-logs"
  role = module.iam_assumable_role.iam_role_name

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "logs:*"
          ],
          "Effect": "Allow",
          "Resource": [
            "*"
          ]
        }
      ]
    }
  EOF
}

resource "aws_iam_role_policy" "lambda_apigateway" {
  name = "apigateway"
  role = module.iam_assumable_role.iam_role_name

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "apigateway:GET",
                    "apigateway:POST",
                    "apigateway:PUT",
                    "apigateway:DELETE",
                    "apigateway:PATCH"
                ],
                "Resource": [
                    "arn:aws:apigateway:*::/restapis",
                    "arn:aws:apigateway:*::/restapis/*",
                    "arn:aws:apigateway:*::/apis",
                    "arn:aws:apigateway:*::/apis/*"
                ]
            }
        ]
    }
  EOF
}

resource "aws_iam_role_policy" "lambda_passrole" {
  name = "passrole"
  role = module.iam_assumable_role.iam_role_name

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "iam:PassRole"
          ],
          "Effect": "Allow",
          "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.environment}-lambda-*"
        }
      ]
    }
  EOF

}

resource "aws_iam_role_policy" "ssm_parameters" {
  name = "ssm-parameters"
  role = module.iam_assumable_role.iam_role_name

  policy = data.aws_iam_policy_document.ssm_parameters.json
}

data "aws_iam_policy_document" "ssm_parameters" {

  statement {
    effect    = "Allow"
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/bodam/deployer/*",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/*/serverless/lambda-role",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/_shared/*",
    ]
  }

  # statement {
  #   effect    = "Allow"
  #   actions   = ["kms:Decrypt"]
  #   resources = ["arn:aws:kms:${data.aws_region.current.name}:${var.account_id}:key/${var.key_id}"]
  # }
}
