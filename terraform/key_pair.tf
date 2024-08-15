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
