output "test_workload_vpc_arn" {
  description = "Test Workload VPC ARN"
  value       = aws_vpc.vpc.arn
}

output "test_workload_subnet_arns" {
  description = "Test Workload Subnet ARNs"
  value       = [for s in aws_subnet.subnet : s.arn]
}