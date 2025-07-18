locals {
  apps               = { for k, v in var.apps : k => v if v.docs.enabled }
  aws_logs_path = "/AWSLogs/${data.aws_caller_identity.identity.account_id}"
  build_dir          = "${path.module}/dist"
  datadog_lambda = [
    for lambda in data.aws_lambda_functions.all.function_names :
    lambda if length(regexall("^DatadogIntegration-ForwarderStack-", lambda)) > 0
  ]
  file_dir           = "${path.module}/files"
  fqdn               = "${var.subdomain}.${var.domain}"
  lambda_dir         = "${path.module}/lambda"
  log_groups = [
    aws_lambda_function.oidc.logging_config[0].log_group
  ]
  prefix             = "cfa-documentation-${var.environment}"
  protected_prefixes = [for k, v in local.apps : k if v.docs.private]
  tags_base = {
    application = local.prefix
    program     = "engineering"
    project     = "cfa-documenation"
    environment = var.environment
  }
  template_dir = "${path.module}/templates"
  tags         = merge(local.tags_base, resource.aws_servicecatalogappregistry_application.docs.application_tag)
}
