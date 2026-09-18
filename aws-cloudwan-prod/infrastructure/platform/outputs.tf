output "global_network_id" {
  description = "Cloud WAN Global Network ID"
  value       = module.cloud_wan_core.global_network_id
}

output "core_network_id" {
  description = "Cloud WAN Core Network ID"
  value       = module.cloud_wan_core.core_network_id
}

output "core_network_arn" {
  description = "Cloud WAN Core Network ARN"
  value       = module.cloud_wan_core.core_network_arn
}