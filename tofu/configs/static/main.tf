terraform {
  backend "s3" {
    bucket         = "shared-services-${var.environment}-tfstate"
    key            = "static.tfstate"
    region         = "us-east-1"
    dynamodb_table = "${var.environment}.tfstate"
  }
}

module "inputs" {
  source = "github.com/codeforamerica/tofu-modules-aws-ssm-inputs?ref=1.0.0"

  prefix = "/${var.infra_project}/${var.environment}"
  inputs = ["logging/bucket", "logging/key", "vpc/id"]
}

resource "aws_servicecatalogappregistry_application" "static" {
  name        = "${var.project}-${var.environment}-static-hosting"
  description = "Static site hosting for Code for America."
}

module "static" {
  source = "../../modules/static-shared"

  domain               = var.domain
  doppler_workspace_id = var.doppler_workspace_id
  environment          = var.environment
  force_delete         = var.force_delete
  logging_bucket       = module.inputs.values["logging/bucket"]
  logging_key_arn      = module.inputs.values["logging/key"]
  program              = var.program
  project              = var.project
  vpc_id               = module.inputs.values["vpc/id"]

  tags = aws_servicecatalogappregistry_application.static.tags
}

module "outputs" {
  source = "github.com/codeforamerica/tofu-modules-aws-ssm-outputs?ref=1.0.0"

  prefix = "/${var.infra_project}/${var.environment}/static"

  outputs = {
    "application/tag"     = aws_servicecatalogappregistry_application.static.application_tag["awsApplication"]
    "bucket/arn"          = module.static.bucket_arn
    "bucket/name"         = module.static.bucket_name
    "distribution/arn"    = module.static.distribution_arn
    "distribution/domain" = module.static.distribution_domain
    "distribution/id"     = module.static.distribution_id
    "kms/key-arn"         = module.static.kms_key_arn
  }

  tags = aws_servicecatalogappregistry_application.static.tags
}
