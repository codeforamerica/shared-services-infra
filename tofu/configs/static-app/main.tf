terraform {
  backend "s3" {
    bucket         = "shared-services-${var.environment}-tfstate"
    key            = "static-app-${var.application}.tfstate"
    region         = "us-east-1"
    dynamodb_table = "${var.environment}.tfstate"
  }
}

module "appspec" {
  source = "../../modules/appspec"

  spec_path = "${abspath(path.module)}/specs/${var.application}.yaml"
}

module "inputs" {
  source = "github.com/codeforamerica/tofu-modules-aws-ssm-inputs?ref=1.0.0"

  prefix = "/${var.infra_project}/${var.environment}/static"
  inputs = ["application/tag", "bucket/arn", "distribution/arn", "kms/key-arn"]
}

resource "aws_servicecatalogappregistry_application" "application" {
  name        = local.prefix
  description = module.appspec.title

  tags = local.tags_base
}

module "app" {
  source   = "../../modules/static-app"
  for_each = module.appspec.enabled && module.appspec.type == "static" ? toset([var.application]) : toset([])

  application_name = module.appspec.name
  bucket_arn       = module.inputs.values["bucket/arn"]
  distribution_arn = module.inputs.values["distribution/arn"]
  kms_key_arn      = module.inputs.values["kms/key-arn"]
  domain           = var.domain
  environment      = var.environment
  project          = var.project
  repo             = module.appspec.repo

  tags = local.tags
}
