resource "aws_db_subnet_group" "finance_web_db_subnet_group" {
  name       = "finance-web-db-subnet-group"
  subnet_ids = [aws_subnet.finance_vm_public_subnet1.id, aws_subnet.finance_vm_public_subnet2.id]

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "aws_db_instance" "finance_web_db" {
  allocated_storage      = 10
  instance_class         = "db.t3.micro"
  engine                 = "postgres"
  engine_version         = "14"
  username               = var.db_user
  password               = var.db_password
  db_name                = "finance_web_db"
  db_subnet_group_name   = aws_db_subnet_group.finance_web_db_subnet_group.name
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.finance_db_sg.id]

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}
