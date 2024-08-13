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

resource "aws_vpc" "app_server_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "app-server"
  }
}

resource "aws_subnet" "app_server_subnet" {
  vpc_id                  = aws_vpc.app_server_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "app-server-subnet"
  }
}

resource "aws_security_group" "app_server_sg" {
  name   = "app-server-sg"
  vpc_id = aws_vpc.app_server_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-server-sg"
  }
}

data "aws_ami" "ubuntu-20-04" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu-20-04.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.app_server_subnet.id
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  tags = {
    Name = "app-server"
  }
}
