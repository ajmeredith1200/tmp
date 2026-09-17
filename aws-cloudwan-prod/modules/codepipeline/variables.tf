variable "deploy_layer" {
  description = "Terraform layer to deploy via CodePipeline"
  type        = string

  validation {
    condition     = contains(["platform", "connectivity", "security", "validation"], var.deploy_layer)
    error_message = "deploy_layer must be one of: platform, connectivity, security, validation."
  }
}

variable "deploy_environment" {
  description = "Environment to deploy via CodePipeline"
  type        = string
  default     = "preprod"

  validation {
    condition     = contains(["preprod", "prd"], var.deploy_environment)
    error_message = "deploy_environment must be one of: preprod, prd."
  }
}

variable "gitlab_provider" {
  description = "GitLab host and path prefix used for cloning the repo"
  type        = string
  default     = "gitlab.com/redcentric/fns/terraform/customers/14545-hays/"
}

variable "gitlab_repo" {
  description = "GitLab repository name to clone"
  type        = string
  default     = "aws-cloudwan-prod"
}

variable "gitlab_token_secret_name" {
  description = "AWS Secrets Manager secret that stores the GitLab token"
  type        = string
  default     = "gitlab-token"
}

variable "gitlab_token_id" {
  description = "GitLab username used in the clone URL"
  type        = string
  default     = "oauth2"
}

variable "gitlab_branch_override" {
  description = "Branch to check out after cloning"
  type        = string
  default     = "main"
}

variable "enable_git_clone_source" {
  description = "When true, use the legacy direct GitLab clone CodeBuild stage instead of the S3 mirror source flow"
  type        = bool
  default     = false
}

variable "create_gitlab_s3_upload_role" {
  description = "When true, create the shared GitLab S3 upload role. Only one layer should set this to true."
  type        = bool
  default     = false
}

variable "terraform_state_bucket_name" {
  description = "Name of the shared Terraform state bucket"
  type        = string
  default     = "aws-cloudwan-terraform-state"
}

variable "terraform_state_key" {
  description = "Terraform state key prefix for the layer"
  type        = string
  default     = "terraform.tfstate"
}
