data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_security_group" "workload" {
  name        = "${var.vm_instance_name}-sg"
  description = "Allow SSH access to the test workload"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.management_cidrs

    content {
      description = "SSH from the approved management network"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  ingress {
    description = "All traffic from private networks"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vm_instance_name}-sg"
  }
}

resource "aws_instance" "workload" {
  depends_on = [ aws_subnet.subnet ]

  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.micro"
  key_name                    = "cloudwan-fw-key"
  subnet_id                   = aws_subnet.subnet["workload_a"].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.workload.id]
  user_data_replace_on_change = true

  user_data = <<-EOF
		#cloud-config
		package_update: true
		package_upgrade: true
		packages:
			- net-tools
			- apache2
	EOF

  tags = {
    Name     = var.vm_instance_name
    Hostname = var.vm_hostname
  }
}
