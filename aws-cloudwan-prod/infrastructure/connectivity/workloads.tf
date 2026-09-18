## Attachment to workload VPCs in remote accounts
## Permission on the remote account needed:
# networkmanager:CreateVpcAttachment
# networkmanager:UpdateVpcAttachment
# networkmanager:DeleteAttachment
# networkmanager:DescribeVpcAttachments
# networkmanager:GetVpcAttachment
# networkmanager:TagResource
# networkmanager:UntagResource

/*resource "aws_networkmanager_vpc_attachment" "test_workload" {
  #provider = aws.eu-west-1
  core_network_id = data.terraform_remote_state.cwan_platform_remote_state.outputs.core_network_id
  vpc_arn         =  "arn:aws:ec2:eu-west-1:151463905441:vpc/vpc-010d617d2aeceac7b"
  subnet_arns     = [
    "arn:aws:ec2:eu-west-1:151463905441:subnet/subnet-05155d0ecb979e402",
    "arn:aws:ec2:eu-west-1:151463905441:subnet/subnet-042e4d176a16da925",
    "arn:aws:ec2:eu-west-1:151463905441:subnet/subnet-0e440a8100b32f7f0"
  ]

  tags = {
    cwan-seg = "workloads",
    Name     = "eu-west-1 test workload attachment"
  }
}*/