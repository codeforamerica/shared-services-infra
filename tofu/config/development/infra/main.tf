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
