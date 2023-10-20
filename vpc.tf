provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"  # Update the CIDR block as needed
}

resource "aws_subnet" "my_subnet" {
  count           = 2
  vpc_id          = aws_vpc.my_vpc.id
  cidr_block      = "10.0.1.0/24"  # Update with appropriate subnets
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "route_to_internet" {
  route_table_id = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_igw.id
}

resource "aws_security_group" "eks_sg" {
  name        = "eks_security_group"
  description = "EKS Security Group"
  vpc_id      = aws_vpc.my_vpc.id
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.my_subnet[*].id
}
