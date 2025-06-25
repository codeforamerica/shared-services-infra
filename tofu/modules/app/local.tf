locals {
  datadog_lambda = [
    for lambda in data.aws_lambda_functions.all.function_names :
    lambda if length(regexall("^DatadogIntegration-ForwarderStack-", lambda)) > 0
  ]
  domain_prefix = var.subdomain == null ? "" : var.subdomain
  log_groups = setunion(
    data.aws_cloudwatch_log_groups.ecs.log_group_names,
    data.aws_cloudwatch_log_groups.ecs_insights.log_group_names,
    data.aws_cloudwatch_log_groups.rds.log_group_names
  )
  oidc_settings = !var.internal ? null : {
    client_secret_arn      = module.secrets.secrets["oidc"].secret_arn
    authorization_endpoint = "https://codeforamerica.okta.com/oauth2/v1/authorize"
    issuer                 = "https://codeforamerica.okta.com"
    token_endpoint         = "https://codeforamerica.okta.com/oauth2/v1/token"
    user_info_endpoint     = "https://codeforamerica.okta.com/oauth2/v1/userinfo"
  }
  production    = var.environment == "production"
  project_short = var.project_short != null ? var.project_short : var.project
  secrets = merge({
    for name, v in var.secrets : name => {
      description = v.description
      tags        = local.tags
      start_value = v.type == "json" ? jsonencode({ for k in v.keys : k => "" }) : ""
    }
    },
    !var.internal ? {} : {
      "oidc" = {
        description = "OIDC secrets for ${var.project} - ${var.environment}"
        tags        = local.tags
        # We need to set something here so that we can use the secret in the
        # OIDC settings for the service module.
        start_value = jsonencode({
          client_id     = "abc",
          client_secret = "123",
        })
      }
    }
  )
  tags = {
    application = "${var.project}-${var.environment}"
    program     = var.program
    project     = var.project
    environment = var.environment
  }
}
