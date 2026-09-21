data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  environment_code = var.deploy_environment
  layer_prefix     = "cwan-euwa-${local.environment_code}-${var.deploy_layer}"
  pipeline_bucket  = "cwan-euwa-${local.environment_code}-s3b-codepipeline-${var.deploy_layer}-01"
  kms_alias_name  = "alias/cwan-euwa-${local.environment_code}-keya-codepipeline-${var.deploy_layer}-01"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = local.pipeline_bucket
}

resource "aws_s3_bucket_versioning" "codepipeline_bucket_versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "artifact_kms_key_policy" {
  statement {
    sid    = "AllowRootAccount"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCodePipelineRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.codepipeline_role.arn]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCodeBuildRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.codebuild_role.arn]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "artifact_key" {
  description             = "KMS key for CodePipeline artifact encryption for ${var.deploy_layer}"
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.artifact_kms_key_policy.json
}

resource "aws_kms_alias" "artifact_alias" {
  name          = local.kms_alias_name
  target_key_id = aws_kms_key.artifact_key.key_id
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${local.layer_prefix}-iamr-codepipeline-01"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]

    resources = [
      aws_kms_key.artifact_key.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetProjects"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "cwan-euwa-${local.environment_code}-${var.deploy_layer}-iamp-codepipeline-01"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${local.layer_prefix}-iamr-codebuild-01"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = [
      "arn:aws:ssm:*::parameter/aws/service/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:ModifyVpcAttribute",
      "ec2:DescribeVpcs",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSubnets",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeSecurityGroups",
      "ec2:CreateTags",
      "ec2:CreateTransitGatewayPolicyTable",
      "ec2:AcceptTransitGatewayPeeringAttachment",
      "ec2:AssociateTransitGatewayPolicyTable*/"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "networkmanager:CreateGlobalNetwork",
      "networkmanager:DeleteGlobalNetwork",
      "networkmanager:Get*",
      "networkmanager:List*",
      "networkmanager:TagResource",
      "networkmanager:UntagResource",
      "networkmanager:CreateVpcAttachment",
      "networkmanager:UpdateVpcAttachment",
      "networkmanager:DeleteAttachment",
      "networkmanager:DescribeVpcAttachments",
      "networkmanager:GetVpcAttachment"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*",
      "arn:aws:s3:::${var.terraform_state_bucket_name}",
      "arn:aws:s3:::${var.terraform_state_bucket_name}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = [
      aws_kms_key.artifact_key.arn,
      "arn:aws:kms:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:key/*",
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "cwan-euwa-${local.environment_code}-${var.deploy_layer}-iamp-codebuild-01"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

data "archive_file" "git_clone_source" {
  count       = var.enable_git_clone_source ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/../../infrastructure/codebuild/buildspec_git-clone.yml"
  output_path = "${path.module}/files/git_clone_source_${var.deploy_layer}.zip"
}

resource "aws_s3_object" "git_clone_source" {
  count      = var.enable_git_clone_source ? 1 : 0
  bucket     = aws_s3_bucket.codepipeline_bucket.id
  key        = "git-clone-source/${basename(data.archive_file.git_clone_source[0].output_path)}"
  source     = data.archive_file.git_clone_source[0].output_path
  source_hash = filemd5(data.archive_file.git_clone_source[0].source_file)
}

resource "aws_codebuild_project" "git_clone" {
  count        = var.enable_git_clone_source ? 1 : 0
  name         = "${local.layer_prefix}-cbp-git-clone-01"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:6.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "CODE_SRC_DIR"
      value = "."
    }

    environment_variable {
      name  = "ENV"
      value = var.deploy_environment
    }

    environment_variable {
      name  = "BRANCH_OVERRIDE"
      value = var.gitlab_branch_override
    }

    environment_variable {
      name  = "GITLAB_TOKEN_SECRET_NAME"
      value = var.gitlab_token_secret_name
    }

    environment_variable {
      name  = "GIT_PROVIDER"
      value = var.gitlab_provider
    }

    environment_variable {
      name  = "GIT_REPO"
      value = var.gitlab_repo
    }

    environment_variable {
      name  = "GIT_TOKEN_ID"
      value = var.gitlab_token_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./${basename(data.archive_file.git_clone_source[0].source_file)}"
  }
}

resource "aws_codebuild_project" "terraform_init" {
  name         = "${local.layer_prefix}-cbp-init-01"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_LAYER"
      value = var.deploy_layer
    }

    environment_variable {
      name  = "TF_ENVIRONMENT"
      value = var.deploy_environment
    }

    environment_variable {
      name  = "TERRAFORM_BACKEND_BUCKET"
      value = var.terraform_state_bucket_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../../infrastructure/codebuild/buildspec_terraform-init.yml")
  }
}

resource "aws_codebuild_project" "terraform_validate" {
  name         = "${local.layer_prefix}-cbp-validate-01"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_LAYER"
      value = var.deploy_layer
    }

    environment_variable {
      name  = "TF_ENVIRONMENT"
      value = var.deploy_environment
    }

    environment_variable {
      name  = "TERRAFORM_BACKEND_BUCKET"
      value = var.terraform_state_bucket_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../../infrastructure/codebuild/buildspec_terraform-validate.yml")
  }
}

resource "aws_codebuild_project" "terraform_plan" {
  name         = "${local.layer_prefix}-cbp-plan-01"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_LAYER"
      value = var.deploy_layer
    }

    environment_variable {
      name  = "TF_ENVIRONMENT"
      value = var.deploy_environment
    }

    environment_variable {
      name  = "TERRAFORM_BACKEND_BUCKET"
      value = var.terraform_state_bucket_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../../infrastructure/codebuild/buildspec_terraform-plan.yml")
  }
}

resource "aws_codebuild_project" "terraform_apply" {
  name         = "${local.layer_prefix}-cbp-apply-01"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_LAYER"
      value = var.deploy_layer
    }

    environment_variable {
      name  = "TF_ENVIRONMENT"
      value = var.deploy_environment
    }

    environment_variable {
      name  = "TERRAFORM_BACKEND_BUCKET"
      value = var.terraform_state_bucket_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../../infrastructure/codebuild/buildspec_terraform-apply.yml")
  }
}

resource "aws_codebuild_project" "terraform_plan_destroy" {
  name         = "${local.layer_prefix}-cbp-plan-destroy-01"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_LAYER"
      value = var.deploy_layer
    }

    environment_variable {
      name  = "TF_ENVIRONMENT"
      value = var.deploy_environment
    }

    environment_variable {
      name  = "TERRAFORM_BACKEND_BUCKET"
      value = var.terraform_state_bucket_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../../infrastructure/codebuild/buildspec_terraform-plan-destroy.yml")
  }
}

resource "aws_codebuild_project" "terraform_destroy" {
  name         = "${local.layer_prefix}-cbp-destroy-01"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_LAYER"
      value = var.deploy_layer
    }

    environment_variable {
      name  = "TF_ENVIRONMENT"
      value = var.deploy_environment
    }

    environment_variable {
      name  = "TERRAFORM_BACKEND_BUCKET"
      value = var.terraform_state_bucket_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../../infrastructure/codebuild/buildspec_terraform-destroy.yml")
  }
}


resource "aws_codepipeline" "codepipeline" {
  name     = "${local.layer_prefix}-cdp-01"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_alias.artifact_alias.arn
      type = "KMS"
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-source-01"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = var.enable_git_clone_source ? {
        S3Bucket             = aws_s3_bucket.codepipeline_bucket.bucket
        S3ObjectKey          = aws_s3_object.git_clone_source[0].key
        PollForSourceChanges = "false"
      } : {
        S3Bucket             = aws_s3_bucket.codepipeline_bucket.bucket
        S3ObjectKey          = "gitlab-source/latest.zip"
        PollForSourceChanges = var.enable_s3_bucket_polling ? "true" : "false"
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_git_clone_source ? [1] : []
    content {
      name = "${local.layer_prefix}-cbp-git-clone-01"

      action {
        name             = "Git-Clone"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["git_clone_output"]
        version          = "1"

        configuration = {
          ProjectName = aws_codebuild_project.git_clone[0].name
        }
      }
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-init-01"

    action {
      name             = "Init"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = var.enable_git_clone_source ? ["git_clone_output"] : ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.terraform_init.name
      }
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-validate-01"

    action {
      name             = "Validate"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["build_output"]
      output_artifacts = ["validate_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_validate.name
      }
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-plan-01"

    action {
      name             = "Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["validate_output"]
      output_artifacts = ["plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_plan.name
      }
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-approve-01"
    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-apply-01"

    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["plan_output"]
      version         = "1"
      configuration = {
        ProjectName = aws_codebuild_project.terraform_apply.name
      }
    }
  }
}

resource "aws_codepipeline" "codepipeline_destroy" {
  name     = "${local.layer_prefix}-cdp-destroy-01"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_alias.artifact_alias.arn
      type = "KMS"
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-source-01"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = var.enable_git_clone_source ? {
        S3Bucket             = aws_s3_bucket.codepipeline_bucket.bucket
        S3ObjectKey          = aws_s3_object.git_clone_source[0].key
        PollForSourceChanges = "false"
      } : {
        S3Bucket             = aws_s3_bucket.codepipeline_bucket.bucket
        S3ObjectKey          = "gitlab-source/latest.zip"
        PollForSourceChanges = var.enable_s3_bucket_polling ? "true" : "false"
      }
    }
  }
  stage {
    name = "${local.layer_prefix}-cbp-init-01"

    action {
      name             = "Init"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = var.enable_git_clone_source ? ["git_clone_output"] : ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.terraform_init.name
      }
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-plan-destroy-01"

    action {
      name             = "Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["validate_output"]
      output_artifacts = ["plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_plan_destroy.name
      }
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-approve-01"
    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "${local.layer_prefix}-cbp-destroy-01"

    action {
      name             = "Destroy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_destroy.name
      }
    }
  }
}
