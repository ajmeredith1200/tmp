resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "subnet" {
  for_each = var.subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = endswith(each.key, "_a") ? var.az1 : endswith(each.key, "_b") ? var.az2 : var.az3

  tags = {
    Name = each.value.name
  }
}

resource "aws_route_table" "workload" {
  vpc_id = aws_vpc.vpc.id

  dynamic "route" {
    for_each = var.management_cidrs

    content {
      cidr_block = route.value
      gateway_id = aws_internet_gateway.igw.id
    }
  }

  tags = {
    Name = var.workload_route_table_name
  }
}

resource "aws_route" "default_to_cwan" {
  depends_on = [
    aws_networkmanager_attachment_accepter.workload
  ]

  route_table_id         = aws_route_table.workload.id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = var.core_network_arn
}

resource "aws_route_table_association" "workload" {
  depends_on = [ aws_subnet.subnet ]
  subnet_id      = aws_subnet.subnet["workload_a"].id
  route_table_id = aws_route_table.workload.id
}


resource "aws_networkmanager_vpc_attachment" "workload" {
  count = var.attach_to_cwan ? 1 : 0

  core_network_id = var.core_network_id
  vpc_arn         = aws_vpc.vpc.arn
  subnet_arns = [
    aws_subnet.subnet["attachment_a"].arn,
    aws_subnet.subnet["attachment_b"].arn,
    aws_subnet.subnet["attachment_c"].arn,
  ]

  tags = var.attachment_tags
}

resource "aws_networkmanager_attachment_accepter" "workload" {
  count = var.attach_to_cwan ? 1 : 0

  attachment_id = aws_networkmanager_vpc_attachment.workload[0].id
  attachment_type = aws_networkmanager_vpc_attachment.workload[0].attachment_type
}