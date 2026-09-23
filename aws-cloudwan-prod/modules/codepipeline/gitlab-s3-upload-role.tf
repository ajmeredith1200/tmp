terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

locals {
  region_code = "euwa"
  gitlab_upload_role_name  = "cwan-${local.region_code}-${var.deploy_environment}-iamr-gitlab-01"
  gitlab_upload_group_name = "cwan-${local.region_code}-${var.deploy_environment}-iamg-gitlab-01"
  gitlab_upload_user_name  = "cwan-${local.region_code}-${var.deploy_environment}-iamu-gitlab-01"
  gitlab_pipeline_buckets = [
    "cwan-euwa-prd-s3b-codepipeline-platform-01",
    "cwan-euwa-prd-s3b-codepipeline-connectivity-01",
    "cwan-euwa-prd-s3b-codepipeline-security-01",
    "cwan-euwa-prd-s3b-codepipeline-validation-01",
  ]
}

data "aws_iam_policy_document" "gitlab_upload_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "gitlab_s3_upload" {
  count = var.create_gitlab_s3_upload_role ? 1 : 0

  name               = local.gitlab_upload_role_name
  assume_role_policy = data.aws_iam_policy_document.gitlab_upload_assume_role.json
}

data "aws_iam_policy_document" "gitlab_s3_upload" {
  statement {
    sid    = "ListAllowedBuckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      for bucket in local.gitlab_pipeline_buckets : "arn:aws:s3:::${bucket}"
    ]
  }

  statement {
    sid    = "WriteGitlabSource"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = [
      for bucket in local.gitlab_pipeline_buckets : "arn:aws:s3:::${bucket}/gitlab-source/*"
    ]
  }
}

resource "aws_iam_role_policy" "gitlab_s3_upload" {
  count = var.create_gitlab_s3_upload_role ? 1 : 0

  name   = "cwan-${local.region_code}-${var.deploy_environment}-iamp-gitlab-01"
  role   = aws_iam_role.gitlab_s3_upload[0].id
  policy = data.aws_iam_policy_document.gitlab_s3_upload.json
}

locals {
  gitlab_upload_principals = compact([
    var.create_gitlab_s3_upload_role ? aws_iam_role.gitlab_s3_upload[0].arn : null,
    var.create_gitlab_s3_upload_user ? aws_iam_user.gitlab_s3_upload[0].arn : null,
  ])
}

resource "aws_iam_group" "gitlab_s3_upload" {
  count = var.create_gitlab_s3_upload_user ? 1 : 0
  name  = local.gitlab_upload_group_name
}

resource "aws_iam_user" "gitlab_s3_upload" {
  count = var.create_gitlab_s3_upload_user ? 1 : 0
  name  = local.gitlab_upload_user_name
}

resource "aws_iam_group_membership" "gitlab_s3_upload" {
  count = var.create_gitlab_s3_upload_user ? 1 : 0

  name = "${local.gitlab_upload_group_name}-membership"

  users = [aws_iam_user.gitlab_s3_upload[0].name]
  group = aws_iam_group.gitlab_s3_upload[0].name
}

resource "aws_iam_group_policy" "gitlab_s3_upload" {
  count = var.create_gitlab_s3_upload_user ? 1 : 0

  name   = "cwan-${local.region_code}-${var.deploy_environment}-iamp-gitlab-01"
  group  = aws_iam_group.gitlab_s3_upload[0].name
  policy = data.aws_iam_policy_document.gitlab_s3_upload.json
}

resource "aws_iam_access_key" "gitlab_s3_upload" {
  count = var.create_gitlab_s3_upload_user ? 1 : 0
  user  = aws_iam_user.gitlab_s3_upload[0].name
}

resource "aws_s3_bucket_policy" "gitlab_s3_upload" {
  count = (var.create_gitlab_s3_upload_role || var.create_gitlab_s3_upload_user) ? 1 : 0

  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = data.aws_iam_policy_document.gitlab_s3_bucket_upload[0].json
}

data "aws_iam_policy_document" "gitlab_s3_bucket_upload" {
  count = (var.create_gitlab_s3_upload_role || var.create_gitlab_s3_upload_user) ? 1 : 0

  statement {
    sid    = "AllowGitlabUploadToSourcePrefix"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.gitlab_upload_principals
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.codepipeline_bucket.arn}/gitlab-source/*",
    ]
  }

  statement {
    sid    = "AllowGitlabListBucketPrefix"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.gitlab_upload_principals
    }

    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.codepipeline_bucket.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["gitlab-source/*"]
    }
  }
}

output "gitlab_s3_upload_role_arn" {
  value = var.create_gitlab_s3_upload_role ? aws_iam_role.gitlab_s3_upload[0].arn : null
}

output "gitlab_s3_upload_user_access_key_id" {
  value     = var.create_gitlab_s3_upload_user ? aws_iam_access_key.gitlab_s3_upload[0].id : null
  sensitive = true
}

output "gitlab_s3_upload_user_secret_access_key" {
  value     = var.create_gitlab_s3_upload_user ? aws_iam_access_key.gitlab_s3_upload[0].secret : null
  sensitive = true
}
