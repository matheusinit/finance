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

  user_data = file("./setup.sh")

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}
