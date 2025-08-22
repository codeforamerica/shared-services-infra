terraform {
  backend "s3" {
    bucket         = "shared-services-development-tfstate"
    key            = "infra.tfstate"
    region         = "us-east-1"
    dynamodb_table = "development.tfstate"
  }
}

# Create hosted zones for DNS.
module "hosted_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 5.0"

  zones = {
    internal = {
      domain_name = "dev.services.cfa.codes"
      comment     = "Default hosted zone for internal services."
    }
    external = {
      domain_name = "dev.codeforamerica.app"
      comment     = "Default hosted zone for external services."
    }
  }
}

module "logging" {
  source = "github.com/codeforamerica/tofu-modules-aws-logging?ref=2.1.0"

  project                  = "shared-services"
  environment              = "development"
  cloudwatch_log_retention = 0
  key_recovery_period      = 7
}

module "vpc" {
  source = "github.com/codeforamerica/tofu-modules-aws-vpc?ref=1.1.1"

  project            = "shared-services"
  environment        = "development"
  cidr               = "10.1.0.0/16"
  single_nat_gateway = true
  logging_key_id     = module.logging.kms_key_arn

  # 10.1.1.1 - 10.1.3.254
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  # 10.1.8.1 - 10.1.19.254
  public_subnets = ["10.1.8.0/22", "10.1.12.0/22", "10.1.16.0/22"]
}

module "appspec" {
  source   = "../../../modules/appspec"
  for_each = local.specs

  spec_path = "${abspath(path.module)}/apps/${each.value}.yaml"
}

module "app" {
  source   = "../../../modules/app"
  for_each = { for app, spec in module.appspec : app => spec if spec.enabled }

  project          = each.value.project
  project_short    = each.value.project_short
  application_name = each.value.title
  environment      = "development"
  program          = each.value.program
  services         = each.value.services
  database_engine  = try(each.value.database.type, null)
  database_version = try(each.value.database.version, null)
  secrets          = try(each.value.secrets, {})
  internal         = try(each.value.internal, true)
  doppler_project  = each.value.doppler.project
  domain = (each.value.domain != null
    ? each.value.domain
    : try(each.value.internal, true) ? module.hosted_zones.route53_zone_name.internal : module.hosted_zones.route53_zone_name.external
  )

  # If we're using one of our shared domain, put the application under a
  # subdomain of its own unless the subdomain is explicitly set.
  subdomain = try(each.value.subdomain != null
    ? each.value.subdomain
    : each.value.domain != null ? null : each.key
  )

  logging_bucket  = module.logging.bucket
  logging_key_arn = module.logging.kms_key_arn
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}
