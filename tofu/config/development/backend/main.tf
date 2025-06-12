terraform {
  backend "s3" {
    bucket         = "shared-services-development-tfstate"
    key            = "backend.tfstate"
    region         = "us-east-1"
    dynamodb_table = "development.tfstate"
  }
}

module "backend" {
  source = "github.com/codeforamerica/tofu-modules-aws-backend?ref=1.1.1"

  project     = "shared-services"
  environment = "development"
}
