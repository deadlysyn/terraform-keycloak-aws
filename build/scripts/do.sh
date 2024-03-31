#!/bin/sh

set -eu

BASENAME=$(basename "${0}")
DIRNAME=$(dirname "${0}")
REGION="${AWS_REGION}"

build() {
  docker build -f "${DIRNAME}/../keycloak/Dockerfile" -t "${IMAGE}:latest" "${DIRNAME}/../keycloak"
  docker tag "${IMAGE}:latest" "${REPO}:latest"
}

deploy() {
  aws ecr get-login-password --region "${REGION}" \
    | docker login --username AWS --password-stdin "${REPO_HOST}"
  docker push "${REPO}:latest"
  aws ecs update-service --region "${REGION}" \
    --force-new-deployment --cluster "${CLUSTER}" --service "${CLUSTER}-svc"
}

usage() {
  cat <<EOF
  USAGE: ${BASENAME} -e <environment> [-b|-d]

  -b  build container image
  -d  deploy service
  -e  environment
EOF
  exit 1
}

# Requires aws cli v2
if ! aws --version | grep -q 'aws-cli/2'; then
  echo "ERROR: awscli v2 required"
  exit 1
fi

BUILD=""; ENVIRONMENT=""; DEPLOY=""
while getopts bde: ARG; do
  case "${ARG}" in
    b) BUILD=1 ;;
    d) DEPLOY=1 ;;
    e) ENVIRONMENT="$OPTARG" ;;
    *) usage ;;
  esac
done

# Need build, deploy or both
[ -z "${BUILD}" ] && [ -z "${DEPLOY}" ] && usage

# Always need environment
[ -z "${ENVIRONMENT}" ] && usage

if [ -e "${DIRNAME}/../../environments/${ENVIRONMENT}/backend.tf" ]; then
  OLDPWD="$PWD"
  cd "${DIRNAME}/../../environments/${ENVIRONMENT}"
  CLUSTER="$(terraform output -raw ecs_cluster)"
  REPO="$(terraform output -raw ecr_repo)"
  cd "${OLDPWD}"
  REPO_HOST=$(echo "${REPO}" | cut -d/ -f1)
  IMAGE=$(echo "${REPO}" | cut -d/ -f2)
else
  echo "ERROR: Build infrastructure before deploying"
  exit 1
fi

# Just build
[ -n "${BUILD}" ] && [ -z "${DEPLOY}" ] && build

# Just deploy
[ -n "${DEPLOY}" ] && [ -z "${BUILD}" ] && deploy

# Build and deploy
[ -n "${BUILD}" ] && [ -n "${DEPLOY}" ] && build && deploy

exit 0
