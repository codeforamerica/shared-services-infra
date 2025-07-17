terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44"
    }

    random = {
      source = "hashicorp/random"
      # 3.7.2 fails for some reason.
      version = "< 3.7.2"
    }
  }
}
