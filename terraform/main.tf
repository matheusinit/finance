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
  region = "us-east-1"
}

resource "aws_s3_bucket" "finance_web_elb_logs_bucket" {
  bucket = "finance-web-db-logs"

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "aws_elb" "finance_web_elb" {
  name = "finance-web-elb"
  # availability_zones = ["us-east-1a", "us-east-1b"]
  subnets = [aws_subnet.finance_vm_public_subnet.id]

  access_logs {
    bucket        = aws_s3_bucket.finance_web_elb_logs_bucket.bucket
    bucket_prefix = "finance-web-elb-logs"
    interval      = 60
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.finance_web_vm.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Nmae = "foobar-terraform-elb"
  }
}
