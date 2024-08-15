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
