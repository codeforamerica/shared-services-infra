terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    doppler = {
      source  = "DopplerHQ/doppler"
      version = "~> 1.21"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.8"
    }
  }
}
