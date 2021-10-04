#!/usr/bin/env bash
# NAME: deploy.sh
# Description: A thin wrapper around docker-compose and docker login/tag/push to facilitate building and deploying the hello-world container to ECR.
# Script assumes that relevant AWS credentials have been exported/configured correctly for the shell invoking this script.
# Blame: Dave Kafuman <dave@daveops.org>

### functions
usage() {
	echo "Usage:"
	echo "    $0 [options]"
	echo "    Options:"
	echo "        -h, --help                        Display this message"
	echo "        -a, --account-id <example>        -a 1234567890"
	echo "        -n, --name <example>              -n hello-world"
	echo "        -r, --region <example>            -r us-east-2"
	echo "        -t, --tag <example>               -t latest"
	echo
	echo "    Example:"
	echo "        $0 -a 1234567890 -n hello-world -r us-east-2 -t latest"
	echo
	exit 2
}

# handy die function to exit with message
die() {
	local message="$1"
	echo
	echo "$(tput setaf 1)${message}$(tput sgr0)"
	echo
	exit 2
}

parse_params() {
	while :; do
		case "${1-}" in
			-h | --help)
				usage
				;;
			-a | --account-id)
				account_id="${2-}"
				shift
				;;
			-r | --region)
				region="${2-}"
				shift
				;;
			-n | --name)
				app_name="${2-}"
				shift
				;;
			-t | --tag)
				tag="${2-}"
				shift
				;;
			-v | --verbose)
				set -x
				;;
			-?*)
				die "Unknown option: $1"
				;;
			*)
				break
				;;
		esac
		shift
	done

	return 0
}

ecr_docker_login() {
	local account_id="${1:-$(aws sts get-caller-identity | jq '.Account' -r)}"
	local region="${2:-${AWS_DEFAULT_REGION}}"

	aws ecr get-login-password --region "${region}" | docker login --username AWS --password-stdin "${account_id}.dkr.ecr.${region}.amazonaws.com" || \
		die "unable to docker login to AWS ECR. Check aws credentials."
}

build_and_push() {
	local account_id="${1:-$(aws sts get-caller-identity | jq '.Account' -r)}"
	local region="${2:-${AWS_DEFAULT_REGION}}"
	local app_name="${3:-hello-world}"
	local tag="${4:-latest}"

	ecr_docker_login "${account_id}" && \
		docker build -t "${account_id}.dkr.ecr.${region}.amazonaws.com/${app_name}:${tag}" . && \
		docker push "${account_id}.dkr.ecr.${region}.amazonaws.com/${app_name}:${tag}"
}

### main
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || \
	die "unable to cd to ${BASH_SOURCE[0]}" # cd to same dir as script

parse_params "$@"
build_and_push "${account_id}" "${region}" "${app_name}" "${tag}"
