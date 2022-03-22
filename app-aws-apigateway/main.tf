locals {
  resource_name = "${var.project_name}-${var.environment}"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.3"

  domain_name               = var.domain_name
  zone_id                   = var.route53_zone_id
  subject_alternative_names = var.subject_alternative_names

  # the api gw requires an issued cert
  wait_for_validation = true
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key => the default encryption will do for now...
resource "aws_cloudwatch_log_group" "apigateway" {
  name              = "apigateway-${local.resource_name}-http"
  retention_in_days = var.apigateway_log_retention_days
}

## API gateway

module "apigateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 1.5"

  name          = "${local.resource_name}-${var.instance_name}-http"
  protocol_type = "HTTP"

  # cors_configuration = {
  #   allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
  #   allow_methods = ["*"]
  #   allow_origins = ["*"]
  # }

  domain_name                 = var.domain_name
  domain_name_certificate_arn = module.acm.acm_certificate_arn

  create_default_stage = true

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.apigateway.arn
  # Common Log Format
  default_stage_access_log_format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }
}

resource "aws_route53_record" "api" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.apigateway.apigatewayv2_domain_name_configuration[0].target_domain_name
    zone_id                = module.apigateway.apigatewayv2_domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

## SSM

resource "aws_ssm_parameter" "apigateway" {
  name  = "/${var.environment}/bodam/deployer/serverless/httpApi/${var.instance_name}/id"
  type  = "String"
  value = module.apigateway.apigatewayv2_api_id
}
