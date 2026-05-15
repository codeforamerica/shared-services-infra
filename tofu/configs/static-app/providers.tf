provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      application = join("-", [var.project, var.environment, var.application])
      environment = var.environment
      project     = var.project
    }
  }
}
