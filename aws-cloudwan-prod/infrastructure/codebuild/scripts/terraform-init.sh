#!/usr/bin/env bash
set -eux

: "${TF_LAYER:?TF_LAYER must be set}"
: "${TF_ENVIRONMENT:?TF_ENVIRONMENT must be set}"
: "${TERRAFORM_VERSION:=1.7.5}"
: "${TERRAFORM_BACKEND_BUCKET:=aws-cloudwan-terraform-state}"

echo "Installing Terraform version ${TERRAFORM_VERSION}"
wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  -O /tmp/terraform.zip
unzip -o /tmp/terraform.zip -d /tmp >/dev/null
install /tmp/terraform /usr/local/bin/terraform
terraform --version

echo "Initializing Terraform for layer ${TF_LAYER} in env ${TF_ENVIRONMENT}"
terraform -chdir="infrastructure/${TF_LAYER}" init \
  -backend-config="bucket=${TERRAFORM_BACKEND_BUCKET}" \
  -backend-config="key=${TF_ENVIRONMENT}/${TF_LAYER}/terraform.tfstate" \
  -backend-config="region=eu-west-1" \
  -backend-config="encrypt=true" \
  -upgrade
