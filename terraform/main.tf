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

resource "aws_s3_bucket" "finance_web_elb_logs_bucket" {
  bucket        = "finance-web-db-logs"
  force_destroy = true
  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "aws_s3_bucket_policy" "allow_elb_write_for_logs" {
  bucket = aws_s3_bucket.finance_web_elb_logs_bucket.bucket

  policy = data.aws_iam_policy_document.allow_elb_write_for_logs.json
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "allow_elb_write_for_logs" {
  statement {
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.finance_web_elb_logs_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.finance_web_elb_logs_bucket.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.finance_web_elb_logs_bucket.arn}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_security_group" "load_balancer_sg" {
  name   = "load_balancer_sg"
  vpc_id = aws_vpc.finance_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}


resource "aws_elb" "finance_web_elb" {
  name = "finance-web-elb"
  # availability_zones = ["us-east-1a", "us-east-1b"]
  subnets         = [aws_subnet.finance_vm_public_subnet.id]
  security_groups = [aws_security_group.load_balancer_sg.id]

  access_logs {
    bucket   = aws_s3_bucket.finance_web_elb_logs_bucket.bucket
    interval = 60
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.finance_web_vm.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb"
  }
}
