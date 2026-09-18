## Security Layer | ap-southeast-2 (Sydney) / Hays Region:ASEB

module "security_ap-southeast-2" {
  source    = "../../modules/security"
  providers = { aws = aws.ap-southeast-2 }
  region                        = "ap-southeast-2"
  vpc_name                      = "cwan-aseb-prd-vpc-inspection-01"
  igw_name                      = "cwan-aseb-prd-igw-01"
  external_route_table_name     = "cwan-aseb-prd-rtb-external-01"
  gwlb_a_route_table_name       = "cwan-aseb-prd-rtb-gwlb-a-01"
  gwlb_b_route_table_name       = "cwan-aseb-prd-rtb-gwlb-b-01"
  attachment_a_route_table_name = "cwan-aseb-prd-rtb-attachment-01"
  attachment_b_route_table_name = "cwan-aseb-prd-rtb-attachment-02"
  nat_gw_a_route_table_name     = "cwan-aseb-prd-rtb-nat-gw-a-01"
  nat_gw_b_route_table_name     = "cwan-aseb-prd-rtb-nat-gw-b-01"
  vpc_cidr                      = "10.68.0.0/23"
  gwlb_name                     = "cwan-aseb-prd-gwlb-inspection-01"
  gwlb_target_group_name        = "cwan-aseb-prd-gwlb-target-01"
  fw1_hostname                  = "FG843ASEB-01"
  fw2_hostname                  = "FG843ASEB-02"
  fw1_instance_name             = "cwan-aseb-prd-c0001"
  fw2_instance_name             = "cwan-aseb-prd-c0002"
  fw1_size                      = "t2.small"
  fw2_size                      = "t2.small"
  fw1_external_pip              = data.terraform_remote_state.cwan_persistent_remote_state.outputs.ap_southeast_2_fw1_external_pip
  fw2_external_pip              = data.terraform_remote_state.cwan_persistent_remote_state.outputs.ap_southeast_2_fw2_external_pip
  natgw1_external_pip           = data.terraform_remote_state.cwan_persistent_remote_state.outputs.ap_southeast_2_natgw1_external_pip
  natgw2_external_pip           = data.terraform_remote_state.cwan_persistent_remote_state.outputs.ap_southeast_2_natgw2_external_pip
  keyname                       = "cloudwan-fw-key"
  az1                           = "ap-southeast-2a"
  az2                           = "ap-southeast-2b"

  subnets = {
    attachment_a = {
      name = "cwan-aseb-1a-prd-sn-attachment-01"
      cidr = "10.68.0.0/28"
    }
    attachment_b = {
      name = "cwan-aseb-1b-prd-sn-attachment-01"
      cidr = "10.68.1.0/28"
    }
    gwlb_a = {
      name = "cwan-aseb-1a-prd-sn-gwlb-01"
      cidr = "10.68.0.16/28"
    }
    gwlb_b = {
      name = "cwan-aseb-1b-prd-sn-gwlb-01"
      cidr = "10.68.1.16/28"
    }
    internal_a = {
      name = "cwan-aseb-1a-prd-sn-internal-01"
      cidr = "10.68.0.32/27"
    }
    internal_b = {
      name = "cwan-aseb-1b-prd-sn-internal-01"
      cidr = "10.68.1.32/27"
    }
    external_a = {
      name = "cwan-aseb-1a-prd-sn-external-01"
      cidr = "10.68.0.64/27"
    }
    external_b = {
      name = "cwan-aseb-1b-prd-sn-external-01"
      cidr = "10.68.1.64/27"
    }
    nat_gw_a = {
      name = "cwan-aseb-1a-prd-sn-nat-gw-01"
      cidr = "10.68.0.96/28"
    }
    nat_gw_b = {
      name = "cwan-aseb-1b-prd-sn-nat-gw-01"
      cidr = "10.68.1.96/28"
    }
  }
  
  core_network_id  = data.terraform_remote_state.cwan_platform_remote_state.outputs.core_network_id
  core_network_arn = data.terraform_remote_state.cwan_platform_remote_state.outputs.core_network_arn

  attachment_tags = {
    cwan-role = "inspection"
  }
}
