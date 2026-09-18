terraform {
  backend "s3" {
    bucket       = "aws-cloudwan-terraform-state"
    key          = "prod/codepipeline.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
