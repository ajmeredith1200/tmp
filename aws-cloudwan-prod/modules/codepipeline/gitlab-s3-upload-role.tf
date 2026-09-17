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
  gitlab_upload_role_name = "gitlab-s3-upload-role"
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
  name   = "gitlab-s3-upload-policy"
  role   = aws_iam_role.gitlab_s3_upload.id
  policy = data.aws_iam_policy_document.gitlab_s3_upload.json
}

output "gitlab_s3_upload_role_arn" {
  value = aws_iam_role.gitlab_s3_upload.arn
}
