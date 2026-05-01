terraform {
  backend "s3" {
    bucket         = "shared-services-${var.environment}-tfstate"
    key            = "static-apps.tfstate"
    region         = "us-east-1"
    dynamodb_table = "${var.environment}.tfstate"
  }
}

module "appspec" {
  source   = "../../modules/appspec"
  for_each = local.specs

  spec_path = "${abspath(path.module)}/apps/${each.value}.yaml"
}

module "inputs" {
  source = "github.com/codeforamerica/tofu-modules-aws-ssm-inputs?ref=1.0.0"

  prefix = "/shared-services/${var.environment}"
  inputs = ["logging/bucket", "vpc/id"]
}

module "static" {
  source = "../../modules/static-app"

  environment    = var.environment
  bucket_name    = var.bucket_name
  force_delete   = var.force_delete
  domain         = var.domain
  program        = var.program
  project        = var.project
  subdomain      = "apps"
  apps           = module.appspec
  logging_bucket = module.inputs.values["logging/bucket"]
  vpc_id         = module.inputs.values["vpc/id"]
}
