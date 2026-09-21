terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet" {
  for_each = var.subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = endswith(each.key, "_a") ? var.az1 : var.az2

  tags = {
    Name = each.value.name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
  }
}

/*resource "aws_eip" "natgw1_external_pip" {
  domain = "vpc"
}

resource "aws_eip" "natgw2_external_pip" {
  domain = "vpc"
}*/

resource "aws_nat_gateway" "nat_gw1" {
  depends_on = [aws_internet_gateway.igw]
  allocation_id = var.natgw1_external_pip
  subnet_id     = aws_subnet.subnet["nat_gw_a"].id

  tags = {
    Name = "NAT GW AZ1"
  }
}

resource "aws_nat_gateway" "nat_gw2" {
  depends_on = [aws_internet_gateway.igw]
  allocation_id = var.natgw2_external_pip
  subnet_id     = aws_subnet.subnet["nat_gw_b"].id

  tags = {
    Name = "NAT GW AZ2"
  }
}

resource "aws_route_table" "external" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.external_route_table_name
  }
}

resource "aws_route_table_association" "external_a" {
  subnet_id      = aws_subnet.subnet["external_a"].id
  route_table_id = aws_route_table.external.id
}

resource "aws_route_table_association" "external_b" {
  subnet_id      = aws_subnet.subnet["external_b"].id
  route_table_id = aws_route_table.external.id
}

resource "aws_route_table" "gwlb_a" {
  depends_on = [ aws_networkmanager_vpc_attachment.security ]
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block       = "10.0.0.0/8"
    core_network_arn = var.core_network_arn
  }

  route {
    cidr_block       = "0.0.0.0/0"
    nat_gateway_id   = aws_nat_gateway.nat_gw1.id
  }

  tags = {
    Name = var.gwlb_a_route_table_name
  }
}

resource "aws_route_table" "gwlb_b" {
  depends_on = [ aws_networkmanager_vpc_attachment.security ]
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block       = "10.0.0.0/8"
    core_network_arn = var.core_network_arn
  }

  route {
    cidr_block       = "0.0.0.0/0"
    nat_gateway_id   = aws_nat_gateway.nat_gw2.id
  }

  tags = {
    Name = var.gwlb_b_route_table_name
  }
}

resource "aws_route_table_association" "gwlb_a" {
  subnet_id      = aws_subnet.subnet["gwlb_a"].id
  route_table_id = aws_route_table.gwlb_a.id
}

resource "aws_route_table_association" "gwlb_b" {
  subnet_id      = aws_subnet.subnet["gwlb_b"].id
  route_table_id = aws_route_table.gwlb_b.id
}

resource "aws_route_table" "attachment_a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbendpoint1.id
  }

  tags = {
    Name = var.attachment_a_route_table_name
  }
}

resource "aws_route_table_association" "attachment_a" {
  subnet_id      = aws_subnet.subnet["attachment_a"].id
  route_table_id = aws_route_table.attachment_a.id
}

resource "aws_route_table" "attachment_b" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbendpoint2.id
  }

  tags = {
    Name = var.attachment_b_route_table_name
  }
}

resource "aws_route_table_association" "attachment_b" {
  subnet_id      = aws_subnet.subnet["attachment_b"].id
  route_table_id = aws_route_table.attachment_b.id
}

resource "aws_networkmanager_vpc_attachment" "security" {
  core_network_id = var.core_network_id
  vpc_arn         = aws_vpc.vpc.arn
  subnet_arns = [
    aws_subnet.subnet["attachment_a"].arn,
    aws_subnet.subnet["attachment_b"].arn,
  ]

  options {
    appliance_mode_support = true
  }

  tags = var.attachment_tags
}

resource "aws_route_table" "nat_gw_az1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block      = "10.0.0.0/8"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbendpoint1.id
  }

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.nat_gw_a_route_table_name
  }
}

resource "aws_route_table_association" "nat_gw_az1_association" {
  subnet_id      = aws_subnet.subnet["nat_gw_a"].id
  route_table_id = aws_route_table.nat_gw_az1.id
}

resource "aws_route_table" "nat_gw_az2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block      = "10.0.0.0/8"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbendpoint2.id
  }

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.nat_gw_b_route_table_name
  }
}

resource "aws_route_table_association" "nat_gw_az2_association" {
  subnet_id      = aws_subnet.subnet["nat_gw_b"].id
  route_table_id = aws_route_table.nat_gw_az2.id
}
