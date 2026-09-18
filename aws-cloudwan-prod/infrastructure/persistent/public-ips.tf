#eu-west-1 Publlic IPs
resource "aws_eip" "eu_west_1_natgw1_external_pip" {
  region = "eu-west-1"
  domain = "vpc"
}

resource "aws_eip" "eu_west_1_natgw2_external_pip" {
  region = "eu-west-1"
  domain = "vpc"
}

resource "aws_eip" "eu_west_1_fw1_external_pip" {
  region = "eu-west-1"
  domain = "vpc"
}

resource "aws_eip" "eu_west_1_fw2_external_pip" {
  region = "eu-west-1"
  domain = "vpc"
}

#eu-central-1 Publlic IPs
resource "aws_eip" "eu_central_1_natgw1_external_pip" {
  region = "eu-central-1"
  domain = "vpc"
}

resource "aws_eip" "eu_central_1_natgw2_external_pip" {
  region = "eu-central-1"
  domain = "vpc"
}

resource "aws_eip" "eu_central_1_fw1_external_pip" {
  region = "eu-central-1"
  domain = "vpc"
}

resource "aws_eip" "eu_central_1_fw2_external_pip" {
  region = "eu-central-1"
  domain = "vpc"
}

#ap-southeast-2 Publlic IPs
resource "aws_eip" "ap_southeast_2_natgw1_external_pip" {
  region = "ap-southeast-2"
  domain = "vpc"
}

resource "aws_eip" "ap_southeast_2_natgw2_external_pip" {
  region = "ap-southeast-2"
  domain = "vpc"
}

resource "aws_eip" "ap_southeast_2_fw1_external_pip" {
  region = "ap-southeast-2"
  domain = "vpc"
}

resource "aws_eip" "ap_southeast_2_fw2_external_pip" {
  region = "ap-southeast-2"
  domain = "vpc"
}

#ap-southeast-4 Publlic IPs
resource "aws_eip" "ap_southeast_4_natgw1_external_pip" {
  region = "ap-southeast-4"
  domain = "vpc"
}

resource "aws_eip" "ap_southeast_4_natgw2_external_pip" {
  region = "ap-southeast-4"
  domain = "vpc"
}

resource "aws_eip" "ap_southeast_4_fw1_external_pip" {
  region = "ap-southeast-4"
  domain = "vpc"
}

resource "aws_eip" "ap_southeast_4_fw2_external_pip" {
  region = "ap-southeast-4"
  domain = "vpc"
}
