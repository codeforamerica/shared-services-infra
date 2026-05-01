locals {
  apps          = var.apps
  aws_logs_path = "/AWSLogs/${data.aws_caller_identity.identity.account_id}"
  build_dir     = "${path.module}/dist"
  datadog_lambda = [
    for lambda in data.aws_lambda_functions.all.function_names :
    lambda if length(regexall("^DatadogIntegration-ForwarderStack-", lambda)) > 0
  ]
  file_dir   = "${path.module}/files"
  fqdn       = "${var.subdomain}.${var.domain}"
  lambda_dir = "${path.module}/lambda"
  log_groups = toset(["/aws/lambda/${local.prefix}-oidc"])
  project            = var.project
  prefix             = join("-", [local.project, var.environment])
  protected_prefixes = keys(local.apps)
  tags_base = {
    application = local.prefix
    program     = var.program
    project     = var.project
    environment = var.environment
  }
  template_dir = "${path.module}/templates"
  tags         = merge(local.tags_base, resource.aws_servicecatalogappregistry_application.static.application_tag)
}
