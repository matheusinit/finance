terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.62"
    }
  }

  required_version = ">= 1.9"
}

provider "aws" {
  region  = "us-east-1"
  profile = "aws-production"
}
