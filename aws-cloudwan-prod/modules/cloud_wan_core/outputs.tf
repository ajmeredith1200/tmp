output "global_network_id" {
  value = aws_networkmanager_global_network.cwan_global_network.id
}

output "core_network_id" {
  value = aws_networkmanager_core_network.cwan_core_network.id
}

output "core_network_arn" {
  value = aws_networkmanager_core_network.cwan_core_network.arn
}
