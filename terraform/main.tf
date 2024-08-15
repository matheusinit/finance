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

resource "aws_vpc" "finance_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "aws_internet_gateway" "finance_igw" {
  vpc_id = aws_vpc.finance_vpc.id
}

resource "aws_route_table" "finance_rt" {
  vpc_id = aws_vpc.finance_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.finance_igw.id
  }

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "aws_subnet" "finance_vm_public_subnet" {
  vpc_id                  = aws_vpc.finance_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.finance_vm_public_subnet.id
  route_table_id = aws_route_table.finance_rt.id
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "finance_vm_sg" {
  name   = "finance-vm-sg"
  vpc_id = aws_vpc.finance_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
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
    App = "finance-web"
    Env = "dev"
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

resource "aws_instance" "finance_web_vm" {
  ami                         = data.aws_ami.ubuntu-20-04.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.finance_vm_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.finance_vm_sg.id]
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.finance_vm_sg.id}"]

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.namespace}-key"
  public_key = tls_private_key.ec2_private_key.public_key_openssh
}

resource "tls_private_key" "ec2_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ec2_private_key_local" {
  filename        = "${var.namespace}-key.pem"
  content         = tls_private_key.ec2_private_key.private_key_pem
  file_permission = "0400"
}

resource "aws_db_instance" "app_server_db" {
  allocated_storage = 5
  instance_class    = "db.t3.micro"
  engine            = "postgres"
  engine_version    = "14.1"
  username          = var.db_user
  password          = var.db_password
}
