provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      application = "cfa-documentation-development"
      environment = "development"
      program     = "engineering"
      project     = "cfa-documentation"
    }
  }
}
