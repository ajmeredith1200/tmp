module "cloud_wan_core" {
  source                   = "../../modules/cloud_wan_core"
  base_policy_document     = data.aws_networkmanager_core_network_policy_document.cwan_prod_policy.json
  cwan_global_network_name = "cwan-glbl-prd-gn-01"
  cwan_core_network_name   = "cwan-glbl-prd-cn-01"
  description              = "Hays Production Cloud WAN"

  tags = {
    Environment = "production"
  }
}

data "aws_networkmanager_core_network_policy_document" "cwan_prod_policy" {

  version = "2025.11"

  core_network_configuration {
    asn_ranges = ["65400-65407"]

    edge_locations {
      location = "eu-west-1"
      asn      = "65400"
    }

    edge_locations {
      location = "eu-central-1"
      asn      = "65401"
    }

    /*     edge_locations {
      location = "ap-southeast-2"
      asn      = "65402"
    }

    edge_locations {
      location = "ap-southeast-4"
      asn      = "65403"
    } */
  }

  segments {
    name                          = "workloads"
    require_attachment_acceptance = true
    isolate_attachments           = true
  }

  network_function_groups {
    name                          = "nfgInspectWorkloads"
    require_attachment_acceptance = false
  }

  segment_actions {
    action  = "send-via"
    segment = "workloads"
    mode    = "single-hop"

    via {
      network_function_groups = ["nfgInspectWorkloads"]

      with_edge_override {
        edge_sets = [
          ["eu-west-1"]
        ]

        use_edge_location = "eu-west-1"
      }

      with_edge_override {
        edge_sets = [
          ["eu-central-1"]
        ]

        use_edge_location = "eu-central-1"
      }
    }
  }

  segment_actions {
    action  = "send-to"
    segment = "workloads"

    via {
      network_function_groups = ["nfgInspectWorkloads"]
    }
  }

  attachment_policies {
    rule_number     = 101
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "cwan-seg"
      value    = "workloads"
    }

    action {
      association_method = "constant"
      segment            = "workloads"
    }
  }

  attachment_policies {
    rule_number     = 201
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "cwan-role"
      value    = "inspection"
    }

    action {
      add_to_network_function_group = "nfgInspectWorkloads"
    }
  }

}

resource "aws_networkmanager_core_network_policy_attachment" "cwan_prod_policy_attachment" {
  core_network_id = module.cloud_wan_core.core_network_id
  policy_document = data.aws_networkmanager_core_network_policy_document.cwan_prod_policy.json
}