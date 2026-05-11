resource "aws_cloudwatch_log_group" "oidc" {
  name              = "/aws/lambda/${local.prefix}-oidc"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.logging_key_arn

  tags = merge({ use = "logging" }, var.tags)
}

resource "aws_cloudwatch_log_subscription_filter" "datadog" {
  depends_on = [aws_cloudwatch_log_group.oidc]
  for_each   = length(local.datadog_lambda) > 0 ? local.log_groups : toset([])

  name            = "datadog"
  log_group_name  = each.value
  filter_pattern  = ""
  destination_arn = data.aws_lambda_function.datadog["this"].arn
}
