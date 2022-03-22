variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "iam_role_policies" {
  description = "Map of canned policies to attach to role"
  type        = map(any)
  default = {
    # https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html#permissions-executionrole-features
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-logging.html#http-api-logging.permissions
    lambda_vpc_access_execution_role = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    lambda_basic_execution_role      = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  }
}
