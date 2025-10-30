terraform {
  backend "s3" {
    bucket         = "shared-services-${var.environment}-tfstate"
    key            = "hosting-foundation.tfstate"
    region         = "us-east-1"
    dynamodb_table = "${var.environment}.tfstate"
  }
}

resource "aws_servicecatalogappregistry_application" "application" {
  name        = "${var.project}-${var.environment}"
  description = "Shared hosting for Code for America."
}

module "backend" {
  source = "github.com/codeforamerica/tofu-modules-aws-backend?ref=1.1.1"

  project     = var.project
  environment = var.environment

  tags = aws_servicecatalogappregistry_application.application.tags
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

  tags = aws_servicecatalogappregistry_application.application.tags
}

module "logging" {
  source = "github.com/codeforamerica/tofu-modules-aws-logging?ref=2.1.1"

  project                  = var.project
  environment              = var.environment
  cloudwatch_log_retention = 0
  key_recovery_period      = 7

  tags = aws_servicecatalogappregistry_application.application.tags
}

module "outputs" {
  source = "../../modules/outputs"

  prefix = "/${var.project}/${var.environment}"

  outputs = {
    "application/tag"         = aws_servicecatalogappregistry_application.application.application_tag["awsApplication"]
    "logging/bucket"          = module.logging.bucket
    "logging/key"             = module.logging.kms_key_arn
    "hosted-zone/internal/id" = module.hosted_zones.route53_zone_name.internal
    "hosted-zone/external/id" = module.hosted_zones.route53_zone_name.external
  }

  tags = aws_servicecatalogappregistry_application.application.tags
}
