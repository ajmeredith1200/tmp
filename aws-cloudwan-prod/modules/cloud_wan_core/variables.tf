variable "description" {
  type        = string
  description = "Description for the Cloud WAN global and core network"
  default     = "AWS Cloud WAN demo global network"
}

variable "cwan_global_network_name" {
  description = "Name of CloudWAN Global Network"
  type        = string
}

variable "cwan_core_network_name" {
  description = "Name of CloudWAN Core Network"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags for Cloud WAN resources"
  default     = {}
}

variable "base_policy_document" {
  type        = string
  description = "Optional base policy document JSON to apply when creating the core network"
  default     = ""
}
