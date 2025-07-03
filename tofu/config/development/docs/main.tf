terraform {
  backend "s3" {
    bucket         = "shared-services-development-tfstate"
    key            = "docs.tfstate"
    region         = "us-east-1"
    dynamodb_table = "development.tfstate"
  }
}

module "docs" {
  source = "../../../modules/docs"

  environment  = "development"
  bucket_name  = "docs.dev.services.cfa.codes"
  force_delete = true
  domain       = "dev.services.cfa.codes"
  subdomain    = "docs"

  # TODO: Get these from app specs.
  prefixes = [
    "cfa-security-controls",
    "cmr-entity-resolution",
    "document-transfer-service",
    "shared-services",
    "tax-benefits-backend",
    "tofu-modules"
  ]

  # Use the same VPC we use for shared hosting.
  # TODO: Use data resources to look this up.
  logging_bucket = "shared-services-development-logs"
  vpc_id         = "vpc-024d66fcc4f521d0a"
}

# Create a redirect from the old documentation domain to the new one.
module "redirect" {
  # TODO: Publish this as a module.
  source = "../../../modules/cloudfront-redirect"

  source_domain = "dev.docs.cfa.codes"
  destination   = "https://docs.dev.services.cfa.codes"

  # The hosted zone for this domain is in another account, so we'll crete the
  # records manually.
  create_records = false
}
