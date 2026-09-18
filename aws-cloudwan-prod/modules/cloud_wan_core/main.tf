terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_networkmanager_global_network" "cwan_global_network" {
  description = var.description

  tags = merge({
    Name        = var.cwan_global_network_name
  }, var.tags)
}

resource "aws_networkmanager_core_network" "cwan_core_network" {
  global_network_id   = aws_networkmanager_global_network.cwan_global_network.id
  create_base_policy  = true
  description         = var.description
  base_policy_document = var.base_policy_document != "" ? var.base_policy_document : null

  tags = merge({
    Name        = var.cwan_core_network_name
  }, var.tags)
}
