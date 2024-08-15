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

resource "aws_db_subnet_group" "finance_web_db_subnet_group" {
  name       = "finance-web-db-subnet-group"
  subnet_ids = [aws_subnet.finance_db_private_subnet_1.id, aws_subnet.finance_db_private_subnet_2.id]

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "aws_db_instance" "finance_web_db" {
  allocated_storage    = 5
  instance_class       = "db.t3.micro"
  engine               = "postgres"
  engine_version       = "14"
  username             = var.db_user
  password             = var.db_password
  db_name              = "finance_web_db"
  db_subnet_group_name = aws_db_subnet_group.finance_web_db_subnet_group.name
  skip_final_snapshot  = true


  tags = {
    App = "finance-web"
    Env = "dev"
  }
}
