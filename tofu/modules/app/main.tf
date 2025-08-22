resource "aws_servicecatalogappregistry_application" "application" {
  name        = "${var.project}-${var.environment}"
  description = var.application_name

  tags = local.tags_base
}

module "secrets" {
  source = "github.com/codeforamerica/tofu-modules-aws-secrets?ref=2.0.0"

  project     = var.project
  environment = var.environment

  secrets    = local.secrets
  tags       = local.tags
  add_suffix = false
}

module "doppler" {
  source     = "github.com/codeforamerica/tofu-modules-aws-doppler?ref=1.0.0"
  depends_on = [module.secrets]
  for_each   = length(local.secrets) > 0 ? toset(["this"]) : toset([])

  doppler_project      = var.doppler_project
  project              = var.project
  environment          = var.environment
  program              = var.program
  kms_key_arns         = [module.secrets.kms_key_arn]
  doppler_workspace_id = "08430c37e2a2889dc220"
  tags                 = local.tags
}

module "service" {
  source   = "github.com/codeforamerica/tofu-modules-aws-fargate-service?ref=1.6.1"
  for_each = var.services

  # Wait for the secrets to be created and synced before creating the service.
  depends_on = [module.secrets, module.doppler]

  project            = var.project
  project_short      = local.project_short
  environment        = var.environment
  public             = try(each.value.public, false)
  service            = each.key
  service_short      = try(each.value.short_name, each.key)
  desired_containers = try(each.value.desired_containers, local.production ? 2 : 1)
  health_check_path  = try(each.value.health_check_path, "/health")
  logging_bucket     = var.logging_bucket
  volumes            = try(each.value.volumes, {})

  domain            = var.domain
  subdomain         = join(".", compact([try(each.value.subdomain, null), local.domain_prefix]))
  create_repository = try(each.value.image, null) == null
  image_url         = try(each.value.image, "")
  repository_arn    = try(each.value.repository_arn, null)
  image_tag         = try(each.value.image_tag, "latest")
  force_delete      = !local.production
  oidc_settings     = local.oidc_settings

  vpc_id                       = var.vpc_id
  private_subnets              = var.private_subnets
  public_subnets               = var.public_subnets
  logging_key_id               = var.logging_key_arn
  container_port               = try(each.value.expose, 3000)
  create_version_parameter     = true
  use_target_group_port_suffix = true

  environment_variables = tomap({
    for k, v in local.database_environment_variables : k => v if v != "" && v != null
  })

  environment_secrets = merge(
    tomap({
      for k, v in local.database_environment_secrets : k => v if v != "" && v != null
    }),
    {
      for k, v in try(each.value.secrets, {}) :
      k => (var.secrets[v.name].type == "json"
        ? "${module.secrets.secrets[v.name].secret_arn}:${v.key}"
        : module.secrets.secrets[v.name].secret_arn
      )
    }
  )

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
