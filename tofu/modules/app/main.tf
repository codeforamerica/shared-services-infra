module "secrets" {
  source = "github.com/codeforamerica/tofu-modules-aws-secrets?ref=1.0.0"

  project     = var.project
  environment = var.environment

  secrets = var.internal ? {
    "oidc" = {
      description = "OIDC secrets for ${var.project} - ${var.environment}"
      tags        = local.tags
      # We need to set something here so that we can use the secret in the
      # OIDC settings for the service module.
      start_value = jsonencode({
        "client_id"     = "abc",
        "client_secret" = "123",
      })
    }
  } : {}
}

module "service" {
  source   = "github.com/codeforamerica/tofu-modules-aws-fargate-service?ref=1.4.0"
  for_each = var.services
  depends_on = [
    module.secrets
  ]

  project            = var.project
  project_short      = local.project_short
  environment        = var.environment
  public             = try(each.value.public, false)
  service            = each.key
  service_short      = try(each.value.short_name, each.key)
  desired_containers = try(each.value.desired_containers, local.production ? 2 : 1)
  health_check_path  = try(each.value.health_check_path, "/health")

  domain    = var.domain
  subdomain = "${try(each.value.subdomain, "www")}${local.domain_prefix}"
  force_delete      = !local.production
  oidc_settings     = local.oidc_settings

  vpc_id                   = var.vpc_id
  private_subnets          = var.private_subnets
  public_subnets           = var.public_subnets
  logging_key_id           = var.logging_key_arn
  container_port           = try(each.value.expose, 3000)
  create_version_parameter = true

  environment_variables = tomap({
    for k, v in local.database_environment_variables : k => v if v != "" && v != null
  })

  environment_secrets = tomap({
    for k, v in local.database_environment_secrets : k => v if v != "" && v != null
  })

  tags = local.tags
}

resource "aws_cloudwatch_log_subscription_filter" "datadog" {
  depends_on = [module.service]
  for_each   = length(local.datadog_lambda) > 0 ? local.log_groups : toset([])

  name            = "datadog"
  log_group_name  = each.value
  filter_pattern  = ""
  destination_arn = data.aws_lambda_function.datadog["this"].arn
}
