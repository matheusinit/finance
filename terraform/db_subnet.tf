data "aws_availability_zones" "available" {}

resource "aws_subnet" "finance_db_private_subnet_1" {
  # count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.finance_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "aws_subnet" "finance_db_private_subnet_2" {
  # count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.finance_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}
