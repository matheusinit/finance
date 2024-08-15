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

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.finance_vm_public_subnet.id
  route_table_id = aws_route_table.finance_rt.id
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
