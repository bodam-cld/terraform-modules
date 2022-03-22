locals {
  resource_name = "${var.project_name}-${var.environment}"
}

#tfsec:ignore:aws-sns-enable-topic-encryption => as these end up as notifications and should not contain very sensitive info anyway
resource "aws_sns_topic" "ops_notification" {
  name = "${local.resource_name}-ops-notification"
}

resource "aws_sns_topic_subscription" "ops_email" {
  topic_arn = aws_sns_topic.ops_notification.arn
  protocol  = "email"
  endpoint  = var.ops_notification_email
}

resource "aws_cloudwatch_metric_alarm" "account_billing_alarm" {
  alarm_name          = "account-billing-alarm"
  alarm_description   = "Consolidated billing alarm >= ${var.billing_alarm.currency} ${var.billing_alarm.monthly_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "28800"
  statistic           = "Maximum"
  threshold           = var.billing_alarm.monthly_threshold
  alarm_actions       = [aws_sns_topic.ops_notification.arn]

  dimensions = {
    currency = var.billing_alarm.currency
  }
}
