output "pipeline_name" {
  description = "Name of the CodePipeline for this layer"
  value       = aws_codepipeline.codepipeline.name
}

output "pipeline_role_arn" {
  description = "ARN of the CodePipeline service role"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild service role"
  value       = aws_iam_role.codebuild_role.arn
}

output "artifact_bucket_name" {
  description = "Name of the layer-specific artifact bucket"
  value       = aws_s3_bucket.codepipeline_bucket.bucket
}
