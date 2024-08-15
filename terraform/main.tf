terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.62"
    }
  }

  required_version = ">= 1.9.4"
}

provider "aws" {
  region = "us-east-1"
}

# resource "aws_db_instance" "app_server_db" {
#   allocated_storage = 5
#   instance_class    = "db.t3.micro"
#   engine            = "postgres"
#   engine_version    = "14.1"
#   username          = var.db_user
#   password          = var.db_password
# }
