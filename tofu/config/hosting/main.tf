terraform {
  backend "s3" {
    bucket         = "shared-services-${var.environment}-tfstate"
    key            = "shared-hosting-application-${var.application}.tfstate"
    region         = "us-east-1"
    dynamodb_table = "${var.environment}.tfstate"
  }
}

module "inputs" {
  source = "github.com/codeforamerica/tofu-modules-aws-ssm-inputs?ref=1.0.0"

  prefix = "/${var.project}/${var.environment}"
  inputs = [
    "application/tag", "hosted-zone/external/id",
    "hosted-zone/internal/id", "logging/bucket", "logging/key",
    "vpc/id", "vpc/private-subnets", "vpc/public-subnets"
  ]
}

module "appspec" {
  source = "../../modules/appspec"

  spec_path = "${abspath(path.module)}/specs/${var.application}.yaml"
}

module "app" {
  source   = "../../modules/app"
  for_each = module.appspec.enabled ? toset([var.application]) : toset([])

  project          = module.appspec.project
  project_short    = module.appspec.project_short
  application_name = module.appspec.title
  environment      = var.environment
  program          = module.appspec.program
  services         = module.appspec.services
  database_engine  = try(module.appspec.database.type, null)
  database_version = try(module.appspec.database.version, null)
  secrets          = try(module.appspec.secrets, {})
  internal         = try(module.appspec.internal, true)
  doppler_project  = module.appspec.doppler.project
  domain = (module.appspec.domain != null
    ? module.appspec.domain
    : try(module.appspec.internal, true) ? module.inputs.values["hosted-zone/internal/id"] : module.inputs.values["hosted-zone/external/id"]
  )

  # If we're using one of our shared domain, put the application under a
  # subdomain of its own unless the subdomain is explicitly set.
  subdomain = try(module.appspec.subdomain != null
    ? module.appspec.subdomain
    : module.appspec.domain != null ? null : each.key
  )

  logging_bucket  = module.inputs.values["logging/bucket"]
  logging_key_arn = module.inputs.values["logging/key"]
  vpc_id          = module.inputs.values["vpc/id"]
  private_subnets = split(",", module.inputs.values["vpc/private-subnets"])
  public_subnets  = split(",", module.inputs.values["vpc/public-subnets"])
}
