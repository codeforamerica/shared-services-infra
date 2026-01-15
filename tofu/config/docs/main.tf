terraform {
  backend "s3" {
    bucket         = "shared-services-${var.environment}-tfstate"
    key            = "docs.tfstate"
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

module "docs" {
  source = "../../modules/docs"

  environment  = var.environment
  bucket_name  = "docs.dev.services.cfa.codes"
  force_delete = true
  domain       = "dev.services.cfa.codes"
  subdomain    = "docs"
  apps         = module.appspec

  # Use the shared services VPC.
  logging_bucket = module.inputs.values["logging/bucket"]
  vpc_id         = module.inputs.values["vpc/id"]
}

# Create a redirect from the old documentation domain to the new one.
module "redirect" {
  # TODO: Publish this as a module.
  source = "../../modules/cloudfront-redirect"

  source_domain = "dev.docs.cfa.codes"
  destination   = "https://docs.dev.services.cfa.codes"

  logging_bucket = module.inputs.values["logging/bucket"]

  # The hosted zone for this domain is in another account, so we'll crete the
  # records manually.
  create_records = false

  tags = aws_servicecatalogappregistry_application.application.tags
}
