####DirectConnect Attachment to CloudWAN
/*resource "aws_networkmanager_dx_gateway_attachment" "euw2_direct_connect" {
  core_network_id            = data.terraform_remote_state.cwan_platform_remote_state.outputs.core_network_id
  direct_connect_gateway_arn = "arn:aws:directconnect::151463905441:dx-gateway/10ab9d59-12b3-4271-a10f-513b4e210e0b"
  edge_locations             = ["eu-west-2", "eu-central-1"]

  tags = {
    cwan-seg = "workloads",
    Name     = "eu-west-1 test workload attachment"
  }
}

resource "aws_networkmanager_attachment_accepter" "directconnect" {
  attachment_id  = aws_networkmanager_dx_gateway_attachment.euw2_direct_connect.id
  attachment_type = aws_networkmanager_dx_gateway_attachment.euw2_direct_connect.attachment_type
}*/

####Transit Gateway Attachment to CloudWAN


/*transit gateway peering

1) we create a peering with the transit gateway
2) need to create transit gateway policy table for the route table in use on transit gateway, and only associate this with the peering (no route table association or propagation)
3) we then create the route table attachment and accepter on cloud wan


Before creating a peering, make sure that the account you use to create the peering has the following permissions:

ec2:CreateTransitGatewayPolicyTable
ec2:AcceptTransitGatewayPeeringAttachment
ec2:AssociateTransitGatewayPolicyTable*/


/*resource "aws_networkmanager_transit_gateway_peering" "euw2_transit_gateway" {
  provider            = aws.eu-west-2
  core_network_id     = data.terraform_remote_state.cwan_platform_remote_state.outputs.core_network_id
  transit_gateway_arn = "arn:aws:ec2:eu-west-2:151463905441:transit-gateway/tgw-070d903ec36cb6eab"
}

resource "aws_networkmanager_transit_gateway_route_table_attachment" "euw2_transit_rt" {
  peering_id                      = aws_networkmanager_transit_gateway_peering.euw2_transit_gateway.id
  transit_gateway_route_table_arn = "arn:aws:ec2:eu-west-2:151463905441:transit-gateway-route-table/tgw-rtb-02a35461049ce87ad"

  tags = {
    cwan-seg = "workloads",
    Name     = "eu-west-1 test workload attachment"
  }
}

resource "aws_networkmanager_attachment_accepter" "directconnect" {
  attachment_id  = aws_networkmanager_transit_gateway_route_table_attachment.euw2_transit_rt.id
  attachment_type = aws_networkmanager_transit_gateway_route_table_attachment.euw2_transit_rt.attachment_type
}*/