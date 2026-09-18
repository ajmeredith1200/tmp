resource "aws_network_interface" "fw1_port0" {
  description = "${var.fw1_hostname} port0"
  subnet_id   = aws_subnet.subnet["external_a"].id

  tags = {
    Name = "${var.fw1_instance_name}_port0"
  }
}

resource "aws_network_interface" "fw1_port1" {
  description       = "${var.fw1_hostname} port1"
  subnet_id         = aws_subnet.subnet["internal_a"].id
  source_dest_check = false

  tags = {
    Name = "${var.fw1_instance_name}_port1"
  }
}

resource "aws_network_interface" "fw2_port0" {
  description = "${var.fw2_hostname} port0"
  subnet_id   = aws_subnet.subnet["external_b"].id

  tags = {
    Name = "${var.fw2_instance_name}_port0"
  }
}

resource "aws_network_interface" "fw2_port1" {
  description       = "${var.fw2_hostname} port1"
  subnet_id         = aws_subnet.subnet["internal_b"].id
  source_dest_check = false

  tags = {
    Name = "${var.fw2_instance_name}_port1"
  }
}

resource "aws_eip_association" "fw1_external_pip_association" {
  allocation_id        = var.fw1_external_pip
  network_interface_id = aws_network_interface.fw1_port0.id
}

resource "aws_eip_association" "fw2_external_pip_association" {
  allocation_id        = var.fw2_external_pip
  network_interface_id = aws_network_interface.fw2_port0.id
}

data "aws_network_interface" "gwlb_interface_az1" {
  depends_on = [aws_vpc_endpoint.gwlbendpoint1]
  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.vpc.id}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "description"
    values = ["*ELB*"]
  }
  filter {
    name   = "availability-zone"
    values = ["${var.az1}"]
  }
}

data "aws_network_interface" "gwlb_interface_az2" {
  depends_on = [aws_vpc_endpoint.gwlbendpoint1]
  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.vpc.id}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "description"
    values = ["*ELB*"]
  }
  filter {
    name   = "availability-zone"
    values = ["${var.az2}"]
  }
}

// Security Group

resource "aws_security_group" "public_allow" {
  name        = "Public Allow"
  description = "Public Allow traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "17"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "17"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "50"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public Allow"
  }
}

resource "aws_security_group" "internal" {
  name        = "Internal"
  description = "Internal traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "internal"
  }
}

resource "aws_network_interface_sg_attachment" "publicattachment1" {
  depends_on           = [aws_network_interface.fw1_port0]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.fw1_port0.id
}

resource "aws_network_interface_sg_attachment" "publicattachment2" {
  depends_on           = [aws_network_interface.fw2_port0]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.fw2_port0.id
}


resource "aws_network_interface_sg_attachment" "publicattachment3" {
  depends_on           = [aws_network_interface.fw1_port1]
  security_group_id    = aws_security_group.internal.id
  network_interface_id = aws_network_interface.fw1_port1.id
}

resource "aws_network_interface_sg_attachment" "publicattachment4" {
  depends_on           = [aws_network_interface.fw2_port1]
  security_group_id    = aws_security_group.internal.id
  network_interface_id = aws_network_interface.fw2_port1.id
}

resource "aws_instance" "fgtvm1" {
  //it will use region, architect, and license type to decide which ami to use for deployment
  ami               = var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.fw1_size
  availability_zone = var.az1
  key_name          = var.keyname
  user_data = templatefile("${var.bootstrap-fgtvm}", {
    hostname         = var.fw1_hostname
    type             = "${var.license_type}"
    adminsport       = "${var.adminsport}"
    vpc_cidr         = var.vpc_cidr
    internal_gateway = cidrhost(aws_subnet.subnet["internal_a"].cidr_block, 1)
    endpointip1      = "${data.aws_network_interface.gwlb_interface_az1.private_ip}"
    endpointip2      = "${data.aws_network_interface.gwlb_interface_az2.private_ip}"
  })

  root_block_device {
    volume_type = "gp2"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
  }

  primary_network_interface {
    network_interface_id = aws_network_interface.fw1_port0.id
  }

  tags = {
    Name = var.fw1_instance_name
  }
}

resource "aws_network_interface_attachment" "port1-attach" {
  instance_id          = aws_instance.fgtvm1.id
  network_interface_id = aws_network_interface.fw1_port1.id
  device_index         = 1
}

resource "aws_instance" "fgtvm2" {
  //it will use region, architect, and license type to decide which ami to use for deployment
  ami               = var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.fw2_size
  availability_zone = var.az2
  key_name          = var.keyname
  user_data = templatefile("${var.bootstrap-fgtvm}", {
    hostname         = var.fw2_hostname
    type             = "${var.license_type}"
    adminsport       = "${var.adminsport}"
    vpc_cidr         = var.vpc_cidr
    internal_gateway = cidrhost(aws_subnet.subnet["internal_b"].cidr_block, 1)
    endpointip1      = "${data.aws_network_interface.gwlb_interface_az1.private_ip}"
    endpointip2      = "${data.aws_network_interface.gwlb_interface_az2.private_ip}"
  })

  root_block_device {
    volume_type = "gp2"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
  }

  primary_network_interface {
    network_interface_id = aws_network_interface.fw2_port0.id
  }

  tags = {
    Name = var.fw2_instance_name
  }
}

resource "aws_network_interface_attachment" "port1-attach-2" {
  instance_id          = aws_instance.fgtvm2.id
  network_interface_id = aws_network_interface.fw2_port1.id
  device_index         = 1
}