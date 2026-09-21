terraform {
  backend "s3" {
    bucket         = "aws-cloudwan-terraform-state"
    key            = "prod/security.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    use_lockfile   = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "terraform_remote_state" "cwan_platform_remote_state" {
  backend = "s3"
  config = {
    bucket         = "aws-cloudwan-terraform-state"
    key            = "prod/platform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

data "terraform_remote_state" "cwan_persistent_remote_state" {
  backend = "s3"
  config = {
    bucket         = "aws-cloudwan-terraform-state"
    key            = "prod/persistent.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.default_region
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}

provider "aws" {
  alias  = "ap-southeast-2"
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "ap-southeast-4"
  region = "ap-southeast-4"
}