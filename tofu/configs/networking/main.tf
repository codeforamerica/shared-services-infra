terraform {
  backend "s3" {
    bucket         = "shared-services-${var.environment}-tfstate"
    key            = "hosting-networking.tfstate"
    region         = "us-east-1"
    dynamodb_table = "${var.environment}.tfstate"
  }
}

module "inputs" {
  source = "github.com/codeforamerica/tofu-modules-aws-ssm-inputs?ref=1.0.0"

  prefix = "/${var.project}/${var.environment}"
  inputs = ["application/tag", "logging/key"]
}

module "vpc" {
  source = "github.com/codeforamerica/tofu-modules-aws-vpc?ref=1.1.2"

  project            = "shared-services"
  environment        = "development"
  cidr               = var.vpc_cidr
  single_nat_gateway = true
  logging_key_id     = module.inputs.values["logging/key"]

  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  tags = { awsApplication : module.inputs.values["application/tag"] }
}

module "outputs" {
  source = "github.com/codeforamerica/tofu-modules-aws-ssm-outputs?ref=1.0.0"

  prefix = "/${var.project}/${var.environment}"

  outputs = {
    "vpc/id"              = module.vpc.vpc_id
    "vpc/private-subnets" = join(",", module.vpc.private_subnets)
    "vpc/public-subnets"  = join(",", module.vpc.public_subnets)
  }

  tags = { awsApplication : module.inputs.values["application/tag"] }
}
