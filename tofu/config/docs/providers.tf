provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      application = "${var.project}-${var.environment}"
      environment = var.environment
      program     = var.program
      project     = var.project
    }
  }
}
