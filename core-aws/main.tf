locals {
  resource_name = "${var.project_name}-${var.environment}"
}

resource "aws_route53_zone" "this" {
  name    = var.technical_domain
  comment = "technical domain"

  lifecycle {
    # reject with an error any plan that would destroy
    # use `terraform state rm` to remove the resource only from the state
    prevent_destroy = true
  }

}
