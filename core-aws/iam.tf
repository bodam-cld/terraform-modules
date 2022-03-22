# https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-assumable-roles
module "iam_assumable_roles" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"
  version = "~> 4.13"

  trusted_role_arns = ["arn:aws:iam::${var.iam_trusted_security_account_id}:root"]

  create_admin_role       = true
  admin_role_name         = "${var.environment}-admin"
  admin_role_requires_mfa = var.iam_roles_require_mfa

  create_poweruser_role       = true
  poweruser_role_name         = "${var.environment}-poweruser"
  poweruser_role_requires_mfa = var.iam_roles_require_mfa

  create_readonly_role       = true
  readonly_role_name         = "${var.environment}-readonly"
  readonly_role_policy_arns  = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
  readonly_role_requires_mfa = false
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.13"

  trusted_role_arns = ["arn:aws:iam::${var.iam_trusted_security_account_id}:root"]

  create_role = true

  role_name         = "${var.environment}-terraform"
  role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
