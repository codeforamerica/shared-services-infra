locals {
  apps_domain   = "apps.${var.domain}"
  aws_logs_path = "/AWSLogs/${data.aws_caller_identity.identity.account_id}"
  build_dir     = "${path.module}/dist"
  datadog_lambda = [
    for lambda in data.aws_lambda_functions.all.function_names :
    lambda if length(regexall("^DatadogIntegration-ForwarderStack-", lambda)) > 0
  ]
  file_dir     = "${path.module}/files"
  lambda_dir   = "${path.module}/lambda"
  log_groups   = toset([aws_cloudwatch_log_group.oidc.name])
  prefix       = "${var.project}-${var.environment}"
  template_dir = "${path.module}/templates"
  tags_base = {
    application = local.prefix
    program     = var.program
    project     = var.project
    environment = var.environment
  }
  tags = merge(local.tags_base, var.tags)
}
