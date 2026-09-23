module "platform_pipeline" {
  source = "../../modules/codepipeline"

  deploy_layer                 = "platform"
  deploy_environment           = "prd"
  gitlab_provider              = "gitlab.com/redcentric/fns/terraform/customers/14545-hays/"
  gitlab_repo                  = "aws-cloudwan-prod"
  gitlab_token_secret_name     = "gitlab-token"
  gitlab_token_id              = "oauth2"
  gitlab_branch_override       = "main"
  create_gitlab_s3_upload_role = true
  create_gitlab_s3_upload_user = true
  terraform_state_bucket_name  = "aws-cloudwan-terraform-state"
  enable_s3_bucket_polling     = false
}

module "connectivity_pipeline" {
  source = "../../modules/codepipeline"

  deploy_layer                 = "connectivity"
  deploy_environment           = "prd"
  gitlab_provider              = "gitlab.com/redcentric/fns/terraform/customers/14545-hays/"
  gitlab_repo                  = "aws-cloudwan-prod"
  gitlab_token_secret_name     = "gitlab-token"
  gitlab_token_id              = "oauth2"
  gitlab_branch_override       = "main"
  create_gitlab_s3_upload_role = false
  create_gitlab_s3_upload_user = false
  terraform_state_bucket_name  = "aws-cloudwan-terraform-state"
  enable_s3_bucket_polling     = false
}

module "security_pipeline" {
  source = "../../modules/codepipeline"

  deploy_layer                 = "security"
  deploy_environment           = "prd"
  gitlab_provider              = "gitlab.com/redcentric/fns/terraform/customers/14545-hays/"
  gitlab_repo                  = "aws-cloudwan-prod"
  gitlab_token_secret_name     = "gitlab-token"
  gitlab_token_id              = "oauth2"
  gitlab_branch_override       = "main"
  create_gitlab_s3_upload_role = false
  create_gitlab_s3_upload_user = false
  terraform_state_bucket_name  = "aws-cloudwan-terraform-state"
  enable_s3_bucket_polling     = false
}

module "validation_pipeline" {
  source = "../../modules/codepipeline"

  deploy_layer                 = "validation"
  deploy_environment           = "prd"
  gitlab_provider              = "gitlab.com/redcentric/fns/terraform/customers/14545-hays/"
  gitlab_repo                  = "aws-cloudwan-prod"
  gitlab_token_secret_name     = "gitlab-token"
  gitlab_token_id              = "oauth2"
  gitlab_branch_override       = "main"
  create_gitlab_s3_upload_role = false
  create_gitlab_s3_upload_user = false
  terraform_state_bucket_name  = "aws-cloudwan-terraform-state"
  enable_s3_bucket_polling     = false
}

module "persistent_pipeline" {
  source = "../../modules/codepipeline"

  deploy_layer                 = "persistent"
  deploy_environment           = "prd"
  gitlab_provider              = "gitlab.com/redcentric/fns/terraform/customers/14545-hays/"
  gitlab_repo                  = "aws-cloudwan-prod"
  gitlab_token_secret_name     = "gitlab-token"
  gitlab_token_id              = "oauth2"
  gitlab_branch_override       = "main"
  create_gitlab_s3_upload_role = false
  create_gitlab_s3_upload_user = false
  terraform_state_bucket_name  = "aws-cloudwan-terraform-state"
  enable_s3_bucket_polling     = false
}

module "pipeline_pipeline" {
  source = "../../modules/codepipeline"

  deploy_layer                 = "codepipeline"
  deploy_environment           = "prod" #this isnt a typo and will be changed on next destroy
  gitlab_provider              = "gitlab.com/redcentric/fns/terraform/customers/14545-hays/"
  gitlab_repo                  = "aws-cloudwan-prod"
  gitlab_token_secret_name     = "gitlab-token"
  gitlab_token_id              = "oauth2"
  gitlab_branch_override       = "main"
  create_gitlab_s3_upload_role = false
  create_gitlab_s3_upload_user = false
  terraform_state_bucket_name  = "aws-cloudwan-terraform-state"
  enable_s3_bucket_polling     = false
}