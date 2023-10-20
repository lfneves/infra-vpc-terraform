provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Environment = "delivery"
    Name = "delivery-vpc"
  }

    lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "my_subnet" {
  count           = 2
  vpc_id          = aws_vpc.my_vpc.id
  cidr_block      = "10.0.0.0/20"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "route_to_internet" {
  route_table_id = aws_route_table.my_route_table.id
  destination_cidr_block = "10.0.16.0/24"
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
