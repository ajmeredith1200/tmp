#eu-west-1 Publlic IPs
resource "aws_eip" "eu_west_1_nat1_external_pip" {
  region = "eu-west-1"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "eu_west_1_nat2_external_pip" {
  region = "eu-west-1"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "eu_west_1_fw1_external_pip" {
  region = "eu-west-1"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "eu_west_1_fw2_external_pip" {
  region = "eu-west-1"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

#eu-central-1 Publlic IPs
resource "aws_eip" "eu_central_1_nat1_external_pip" {
  region = "eu-central-1"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "eu_central_1_nat2_external_pip" {
  region = "eu-central-1"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "eu_central_1_fw1_external_pip" {
  region = "eu-central-1"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "eu_central_1_fw2_external_pip" {
  region = "eu-central-1"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

#ap-southeast-2 Publlic IPs
resource "aws_eip" "ap_southeast_2_nat1_external_pip" {
  region = "ap-southeast-2"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "ap_southeast_2_nat2_external_pip" {
  region = "ap-southeast-2"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "ap_southeast_2_fw1_external_pip" {
  region = "ap-southeast-2"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "ap_southeast_2_fw2_external_pip" {
  region = "ap-southeast-2"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

#ap-southeast-4 Publlic IPs
resource "aws_eip" "ap_southeast_4_nat1_external_pip" {
  region = "ap-southeast-4"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "ap_southeast_4_nat2_external_pip" {
  region = "ap-southeast-4"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "ap_southeast_4_fw1_external_pip" {
  region = "ap-southeast-4"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "ap_southeast_4_fw2_external_pip" {
  region = "ap-southeast-4"
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}
