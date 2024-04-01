#!/bin/sh

# ECS 1.3
if [ -n "${ECS_CONTAINER_METADATA_URI}" ]; then
  EXTERNAL_ADDR=$(curl -fs "${ECS_CONTAINER_METADATA_URI}" \
    | jq -r '.Networks[0].IPv4Addresses[0]')
fi

# ECS 1.4
if [ -n "${ECS_CONTAINER_METADATA_URI_V4}" ]; then
  EXTERNAL_ADDR=$(curl -fs "${ECS_CONTAINER_METADATA_URI_V4}" \
    | jq -r '.Networks[0].IPv4Addresses[0]')
fi

if [ -z "${EXTERNAL_ADDR}" ]; then
  EXTERNAL_ADDR=127.0.0.1
fi
export EXTERNAL_ADDR


if [ -z "${HOSTNAME}" ]; then
  HOSTNAME="localhost"
fi

# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/x-forwarded-headers.html
exec /opt/keycloak/bin/kc.sh start --optimized --proxy-headers xforwarded "$@"
exit $?
