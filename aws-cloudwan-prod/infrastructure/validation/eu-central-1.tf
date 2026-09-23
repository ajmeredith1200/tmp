## Validation Layer | eu-central-1 (Frankfurt) / Hays Region:EUCA

module "test_workload_eu-central-1" {
  source    = "../../modules/test_workload"
  providers = { aws = aws.eu-central-1 }

  # Automatically attach the test workload VPC to the Cloud WAN. Select false if you want to manually attach via the connecivity layer.
  attach_to_cwan   = true

  vpc_name         = "cwan-euca-prd-vpc-testworkload-01"
  vpc_cidr         = "10.66.5.0/24"
  vm_hostname      = "TESTVM02"
  vm_instance_name = "cwan-euca-dev-c0001"

  workload_route_table_name = "cwan-euca-prd-rtb-testworkload-01"
  az1                       = "eu-central-1a"
  az2                       = "eu-central-1b"
  az3                       = "eu-central-1c"

  attachment_tags = {
    cwan-seg = "workloads"
  }

  management_cidrs = [
    "83.98.0.156/32",
  ]

  subnets = {
    attachment_a = {
      name = "testworkload-euca-1a-prd-sn-attachment-01"
      cidr = "10.66.5.208/28"
    }
    attachment_b = {
      name = "testworkload-euca-1b-prd-sn-attachment-01"
      cidr = "10.66.5.224/28"
    }
    attachment_c = {
      name = "testworkload-euca-1c-prd-sn-attachment-01"
      cidr = "10.66.5.240/28"
    }
    workload_a = {
      name = "testworkload-euca-1a-prd-sn-application-01"
      cidr = "10.66.5.0/26"
    }
  }
  
  core_network_id  = data.terraform_remote_state.cwan_platform_remote_state.outputs.core_network_id
  core_network_arn = data.terraform_remote_state.cwan_platform_remote_state.outputs.core_network_arn
}


