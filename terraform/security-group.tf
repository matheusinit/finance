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
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
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

resource "aws_security_group" "finance_db_sg" {
  name   = "finance-db-sg"
  vpc_id = aws_vpc.finance_vpc.id

  ingress {
    description = "TCP"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    description     = "EC2 VM"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.finance_vm_sg.id]
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