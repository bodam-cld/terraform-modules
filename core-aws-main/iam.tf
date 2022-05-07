# https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html
# # https://github.com/terraform-aws-modules/terraform-aws-iam/

module "iam_group_users" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4.13"

  name = "users"

  attach_iam_self_management_policy = true
  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess",
  ]
}

module "iam_group_super_admins" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4.13"

  name = "super-admins"
  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
  ]
}

module "iam_assume_groups" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "~> 4.13"

  for_each = var.iam_assume_groups

  name            = each.key
  assumable_roles = each.value.roles
}

# CI deployer user
resource "aws_iam_user" "ci_deployer" {
  name = "ci-deployer"
}

resource "aws_iam_access_key" "ci_deployer" {
  user = aws_iam_user.ci_deployer.name
}

data "aws_iam_policy_document" "ci_deployer_assume_policies" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = var.ci_deployer_role_arns
  }
}

resource "aws_iam_user_policy" "ci_deployer_assume" {
  name   = "assume-policies"
  user   = aws_iam_user.ci_deployer.name
  policy = data.aws_iam_policy_document.ci_deployer_assume_policies.json
}
