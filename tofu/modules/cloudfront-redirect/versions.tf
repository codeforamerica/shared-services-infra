terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      version = "~> 5.93"
      source  = "hashicorp/aws"
    }
  }
}
