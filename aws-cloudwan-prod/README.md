# AWS Cloud WAN Production (DRAFT README)

Terraform configuration for the Hays AWS Cloud WAN environment. The repository provisions the Cloud WAN core network, regional inspection VPCs, shared public IP allocations, workload connectivity, validation resources, and the CodePipeline/CodeBuild automation used to deploy them.

## Repository layout

| Directory | Purpose |
| --- | --- |
| `infrastructure/bootstrap` | Creates the encrypted, versioned S3 bucket used for Terraform state. |
| `infrastructure/persistent` | Allocates regional Elastic IP addresses for FortiGate and NAT gateway interfaces. |
| `infrastructure/platform` | Creates the Cloud WAN core network, segments, network-function group, and routing policy. |
| `infrastructure/security` | Deploys regional inspection VPCs, Gateway Load Balancers, NAT gateways, and FortiGate instances. |
| `infrastructure/connectivity` | Holds external and workload attachment configuration. Some example resources are currently commented out. |
| `infrastructure/validation` | Deploys the test workload VPC in `eu-west-1`. |
| `infrastructure/codepipeline` | Creates the CI/CD pipelines for the Terraform layers. |
| `modules` | Reusable Terraform modules for Cloud WAN, security, CodePipeline, and test workloads. |

The configured regions are:

- `eu-west-1`
- `eu-central-1`
- `ap-southeast-2`
- `ap-southeast-4`

## Prerequisites

- Terraform `>= 1.7.0`.
- AWS credentials with permissions for Cloud WAN, EC2/VPC, ELB/GWLB, IAM, S3, KMS, CodePipeline, and CodeBuild resources.
- All configured AWS regions enabled in the target account.
- An EC2 key pair named `cloudwan-fw-key` for the FortiGate instances.
- Access to the required FortiGate AMI and licensing model. Review the variables in `modules/security` before deployment.
- Bash, AWS CLI, `zip`, `wget`, and `unzip` for the repository scripts.
- Optional quality tools: `pre-commit`, `tflint`, `tfsec`, `checkov`, and `doctoc`.

The CodePipeline configuration also expects a Secrets Manager secret named `gitlab-token` with the token field `oauth2`.

## Terraform state

Bootstrap the state bucket before initializing the other layers. The standard backend is an encrypted S3 backend in `eu-west-1`:

```text
Bucket: aws-cloudwan-terraform-state
Locking: S3 lock file (use_lockfile = true)
```

Some layer provider files contain explicit backend keys such as `prd/platform.tfstate`. The wrapper instead builds keys from the configured stack, environment, and layer:

```text
<stack>/<environment>/<layer>/terraform.tfstate
```

Keep the backend key convention consistent across local and CI runs. Do not initialize a layer against a new key without confirming which state is authoritative.

## Local workflow

The wrapper runs Terraform from the selected `infrastructure/<layer>` directory and supports `prod` and `preprod` environments. A typical workflow is:

```bash
./tf_wrapper.sh -e prod -l platform -s init
./tf_wrapper.sh -e prod -l platform -s validate
./tf_wrapper.sh -e prod -l platform -s plan
./tf_wrapper.sh -e prod -l platform -s apply
```

Use `init_plan_apply` for the combined workflow with an interactive confirmation before apply:

```bash
./tf_wrapper.sh -e prod -l platform -s init_plan_apply
```

Other supported stages are `init`, `validate`, `plan`, `apply`, `destroy`, `show`, `state`, `lint`, `fmt`, and `init_plan`. Pass additional Terraform arguments with `-a`:

```bash
./tf_wrapper.sh -e prod -l platform -s plan -a '-target=module.cloud_wan_core'
```

Repository-wide maintenance commands:

```bash
./tf_wrapper.sh -g    # format and lint all layers
./tf_wrapper.sh -i    # install the pre-commit hook
./tf_wrapper.sh -r    # update the table of contents
```

Use `-s state -a '<terraform state command>'` for state operations, for example:

```bash
./tf_wrapper.sh -e prod -l platform -s state -a 'list'
```

## Deployment order

Apply the layers in dependency order:

1. Bootstrap the Terraform state bucket.
2. Allocate persistent public IP addresses.
3. Deploy the Cloud WAN platform.
4. Deploy the regional security inspection VPCs and FortiGate appliances.
5. Configure connectivity attachments.
6. Deploy the validation workload.

The CodePipeline configuration currently creates pipelines for platform, connectivity, security, and validation. Bootstrap and persistent resources require separate handling unless an equivalent pipeline is added.

## CI/CD

CodeBuild executes the scripts under `infrastructure/codebuild/scripts`:

- `terraform-init.sh`
- `terraform-validate.sh`
- `terraform-plan.sh`
- `terraform-apply.sh`
- `terraform-destroy-plan.sh`
- `terraform-destroy.sh`

Buildspec files in `infrastructure/codebuild` define the corresponding build phases. Review the selected environment, layer, backend configuration, and Terraform variables before approving an apply or destroy operation.

## Security architecture

Each regional inspection VPC is designed with separate external, internal, Gateway Load Balancer, attachment, and NAT gateway subnets across two Availability Zones. Traffic is inspected by two FortiGate instances behind a Gateway Load Balancer before reaching the workload segment.

The Cloud WAN policy defines a `workloads` segment and the inspection network-function routing actions. The validation workload is attached to that segment in `eu-west-1` and is intended to provide a controlled end-to-end deployment check.

## Useful checks

```bash
terraform fmt --check --recursive
tflint --recursive
```

Run Terraform validation through the wrapper after selecting the target environment and layer. Never apply a plan without reviewing its resource changes and confirming that it uses the intended state key.
