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

  # Use the same VPC we use for shared hosting.
  # TODO: Use data resources to look this up.
  logging_bucket = "shared-services-development-logs"
  vpc_id         = "vpc-024d66fcc4f521d0a"
  public_subnets = [
    "subnet-04a634af483d94adb",
    "subnet-0ff03c3903c4c785c",
    "subnet-037226b6f514e6dd1"
  ]
}
