#!/usr/bin/env bash
# Terraform wrapper script

config_file="./tf_wrapper.conf"

usage() {
	echo "Usage: $0 -e <prod|preprod> -l <layer> -s <init|validate|plan|apply|plan_apply|destroy|show|lint|fmt|state|init_plan|init_plan_apply>"
	echo
	echo "-e (environment) <prod|preprod>"
	echo -n "-l (layer) <"
	layers
	echo ">"
	echo "-s (stage) terraform command being wrapped <init|validate|plan|apply|show|destroy|lint|fmt|state|init_plan_apply>"
	echo "   <state> requires additional arguments to be passed via -a in order to define the desired state command"
	echo "   e.g. -s state -a 'mv resource_x resource_y'"
	echo "   <init_plan> runs both operations"
	echo "   <init_plan_apply> runs all three operations, prompting the user to continue before the apply"
	echo "-i install pre-commit hooks"
	echo "-g git-prep - lint and format all layers"
	echo "-a \"<additional_terraform_arguments\" appends any arbitrary additional arguments to the terraform command - e.g. -target=my.resource"

}

die() {
	echo "ERROR - $1"
	exit 1
}

promt_continue() {
	read -p "Do you want to proceed? (y/n) " yn

	case $yn in
	y | Y | yes | YES)
		echo "Proceeding..."
		;;
	n | N | no | NO)
		echo "Exiting..."
		exit
		;;
	*)
		echo "Invalid response. Exiting..."
		exit 1
		;;
	esac
}

load_config() {
	# Read config and replace any %TOKENS% with $variables defined in this script
	config=$(cat $config_file)
	for token in $(grep -oE '%[^%]+%' $config_file | tr -d '%'); do
		var=$(echo $token | tr '[:upper:]' '[:lower:]')
		config=$(echo "$config" | sed "s/%$token%/${!var}/g")
	done
	eval "$config"
}

clean_plans() {
	find "./config/${environment}" -name \*-tfplan -delete
}

layers() {
	find infrastructure -mindepth 1 -maxdepth 1 -type d | sed -e 's/^.*\///g' -e 's/$/|/' | xargs echo -n |
		sed -e 's/ //g' -e 's/|$//'
}

#some color
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Initialize options
install_pre_commit=false
readme_update=false
git_prep=false
while getopts e:l:p:s:irga: flag; do
	case "${flag}" in
	e) environment=${OPTARG} ;;
	l) layer=${OPTARG} ;;
	p) profile=${OPTARG} ;;
	s) stage=${OPTARG} ;;
	i) install_pre_commit=true ;;
	r) readme_update=true ;;
	g) git_prep=true ;;
	a) additional_arguments=${OPTARG} ;;
	*)
		usage
		die
		;;
	esac
done

layer_config_dir="infrastructure/${layer}/config/${environment}"
tfvars="${layer_config_dir}/terraform.tfvars"

if [ -f "$tfvars" ]; then
	var_file_present=true
else
	var_file_present=false
fi

# Function to check and apply updates
update_script() {
	new_script="tf_wrapper_new.sh"
	if [ -f "$new_script" ]; then
		echo "Removing old update file $new_script"
		rm $new_script
	fi
	echo "Checking for new version of wrapper..."
	set -o pipefail
	if ! git archive --remote=git@gitlab.com:redcentric/csg-delivery/terraform-framework-template-v2.git $update_branch tf_wrapper.sh | tar xO >$new_script; then
		echo "Update check failed"
		exit 1
	fi
	set +o pipefail
	echo "Diff with script from HEAD:"
	diff $0 $new_script
	diff_code=$?
	if [ $diff_code -eq 0 ]; then
		echo "No wrapper update available."
		rm $new_script
	elif [ $diff_code -eq 1 ]; then
		echo "New version of wrapper found, updating."
		if bash -n $new_script; then
			chmod +x $new_script
			mv $new_script $0
			rm $new_script
			echo "Script updated. Restarting."
			exec "$0" "$@"
		else
			die "New script $new_script is not valid bash. Aborting update."
		fi
	fi
}


if [ -f "$tfvars" ]; then
	stack=$(sed -n 's/^stack[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$tfvars")
	if [ -z "$stack" ]; then
		echo "Warning: stack is not set in $tfvars; continuing without tfvars-backed stack config."
	fi
fi

# Load config after defining stack name and other required variables from the script arguments
load_config

# Run update
$auto_update && update_script "$@"

if [ $OPTIND -eq 1 ]; then
	usage
	die "No arguments provided. Exiting"
fi

if $install_pre_commit; then
	echo "Installing pre-commit hooks. Use git --no-verify to ignore them"
	cp src/hooks/pre-commit .git/hooks/
	chmod +x .git/hooks/pre-commit
	exit 0
fi

# Add any commands required to update the README.md here
if $readme_update; then
	echo "Updating README"
	doctoc README.md
	exit 0
fi

if $git_prep; then
	echo "formatting recursively"
	terraform fmt --recursive
	echo "linting recursively"
	# Blank spaces after the last arg triggers a deprecation warning from tflint
	[ -z "${lint_args}" ] || lint_args=" ${lint_args}"
	tflint --recursive"${lint_args}"
	exit 0
fi

echo -e "Trigger CI with these arguments"
echo -e "Environment: ${GREEN}$environment${NC}"
echo -e "layer: ${GREEN}$layer${NC}"
echo -e "profile: ${GREEN}$profile${NC}"

cd "infrastructure/${layer}" || die "Unable to change directory to infrastructure/${layer}"
pwd

export TF_DATA_DIR="./config/${environment}/.terraform"
config_dir="./config/${environment}"
tfvars="${config_dir}/terraform.tfvars"

if [ "$var_file_present" = true ] && [ -f "$tfvars" ]; then
	var_args=("-var-file=$tfvars" "-var=layer=$layer" "-var=environment=$environment")
	backend_bucket=$(sed -n 's/^bucket[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$tfvars")
	backend_region=$(sed -n 's/^region[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$tfvars")
	backend_encrypt=$(sed -n 's/^encrypt[[:space:]]*=[[:space:]]*\(.*\)/\1/p' "$tfvars")
	backend_dynamodb_table=$(sed -n 's/^dynamodb_table[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$tfvars")
	backend_args=(
		"-backend-config=region=${backend_region}"
		"-backend-config=bucket=${backend_bucket}"
		"-backend-config=key=${backend_key}"
		"-backend-config=dynamodb_table=${backend_dynamodb_table}"
		"-backend-config=encrypt=${backend_encrypt}"
	)
else
	var_args=("-var=layer=$layer" "-var=environment=$environment")
	backend_args=()
fi

tf_init() {
	echo -e "Tf init and get. Env: ${GREEN}$environment${NC}"
	echo "terraform init \"${backend_args[@]}\" -upgrade"
	terraform init "${backend_args[@]}" -upgrade
}

tf_plan() {
	echo -e "Tf plan. Env: ${GREEN}$environment${NC}"
	pwd
	cat "$tfvars"
	terraform plan \
		-input=false \
		${var_args[@]} \
		-out "${config_dir}/${plan}" \
		$additional_arguments
	echo -e "Tf plan is ${config_dir}/${plan}"
	ls -la "${config_dir}/${plan}" || die "Terraform plan failed"
}

tf_apply() {
	echo -e "Tf Apply. Env: ${GREEN}$environment${NC}"
	echo -e "${GREEN}Tf plan that is being applied is ${config_dir}/${plan}${NC}"
	terraform apply "${config_dir}/${plan}"
	clean_plans
}

case "${stage}" in
"init")
	tf_init
	;;
"validate")
	echo -e "Tf Validate. Env: ${GREEN}$environment${NC}"
	terraform validate
	;;
"plan")
	tf_plan
	;;
"apply")
	tf_apply
	;;
"init_plan")
	tf_init
	tf_plan
	;;
"init_plan_apply")
	tf_init
	tf_plan
	promt_continue
	tf_apply
	;;
"destroy")
	if [ -f "$tfvars" ]; then
		ls -lrt $tfvars
		cat $tfvars
	fi
	pwd
	terraform destroy \
		${var_args[@]} \
		$additional_arguments
	;;
	"show")
	if [ -f "$tfvars" ]; then
		ls -lrt $tfvars
		cat $tfvars
	fi
	;;

"lint")
	tflint "${lint_args}"
	;;

"fmt")
	terraform fmt
	;;

"state")
	terraform state $additional_arguments
	;;

esac
