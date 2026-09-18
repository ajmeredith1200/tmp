## Security Layer | eu-central-1 (Frankfurt) / Hays Region:EUCA

module "security_eu-central-1" {
  source    = "../../modules/security"
  providers = { aws = aws.eu-central-1 }
  region                        = "eu-central-1"
  vpc_name                      = "cwan-euca-prd-vpc-inspection-01"
  igw_name                      = "cwan-euca-prd-igw-01"
  external_route_table_name     = "cwan-euca-prd-rtb-external-01"
  gwlb_a_route_table_name       = "cwan-euca-prd-rtb-gwlb-a-01"
  gwlb_b_route_table_name       = "cwan-euca-prd-rtb-gwlb-b-01"
  attachment_a_route_table_name = "cwan-euca-prd-rtb-attachment-01"
  attachment_b_route_table_name = "cwan-euca-prd-rtb-attachment-02"
  nat_gw_a_route_table_name     = "cwan-euca-prd-rtb-nat-gw-a-01"
  nat_gw_b_route_table_name     = "cwan-euca-prd-rtb-nat-gw-b-01"
  vpc_cidr                      = "10.66.0.0/23"
  gwlb_name                     = "cwan-euca-prd-gwlb-inspection-01"
  gwlb_target_group_name        = "cwan-euca-prd-gwlb-target-01"
  fw1_hostname                  = "FG842EUCA-01"
  fw2_hostname                  = "FG842EUCA-02"
  fw1_instance_name             = "cwan-euca-prd-c0001"
  fw2_instance_name             = "cwan-euca-prd-c0002"
  fw1_size                      = "t2.small"
  fw2_size                      = "t2.small"
  fw1_external_pip              = data.terraform_remote_state.cwan_persistent_remote_state.outputs.eu_central_1_fw1_external_pip
  fw2_external_pip              = data.terraform_remote_state.cwan_persistent_remote_state.outputs.eu_central_1_fw2_external_pip
  natgw1_external_pip           = data.terraform_remote_state.cwan_persistent_remote_state.outputs.eu_central_1_natgw1_external_pip
  natgw2_external_pip           = data.terraform_remote_state.cwan_persistent_remote_state.outputs.eu_central_1_natgw2_external_pip
  keyname                       = "cloudwan-fw-key"
  az1                           = "eu-central-1a"
  az2                           = "eu-central-1b"

  subnets = {
    attachment_a = {
      name = "cwan-euca-1a-prd-sn-attachment-01"
      cidr = "10.66.0.0/28"
    }
    attachment_b = {
      name = "cwan-euca-1b-prd-sn-attachment-01"
      cidr = "10.66.1.0/28"
    }
    gwlb_a = {
      name = "cwan-euca-1a-prd-sn-gwlb-01"
      cidr = "10.66.0.16/28"
    }
    gwlb_b = {
      name = "cwan-euca-1b-prd-sn-gwlb-01"
      cidr = "10.66.1.16/28"
    }
    internal_a = {
      name = "cwan-euca-1a-prd-sn-internal-01"
      cidr = "10.66.0.32/27"
    }
    internal_b = {
      name = "cwan-euca-1b-prd-sn-internal-01"
      cidr = "10.66.1.32/27"
    }
    external_a = {
      name = "cwan-euca-1a-prd-sn-external-01"
      cidr = "10.66.0.64/27"
    }
    external_b = {
      name = "cwan-euca-1b-prd-sn-external-01"
      cidr = "10.66.1.64/27"
    }
    nat_gw_a = {
      name = "cwan-euca-1a-prd-sn-nat-gw-01"
      cidr = "10.66.0.96/28"
    }
    nat_gw_b = {
      name = "cwan-euca-1b-prd-sn-nat-gw-01"
      cidr = "10.66.1.96/28"
    }
  }

  core_network_id  = data.terraform_remote_state.cwan_platform_remote_state.outputs.core_network_id
  core_network_arn = data.terraform_remote_state.cwan_platform_remote_state.outputs.core_network_arn

  attachment_tags = {
    cwan-role = "inspection"
  }
}
