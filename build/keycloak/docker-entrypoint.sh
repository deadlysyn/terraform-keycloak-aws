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

# Add admin user
if [ -n "${KEYCLOAK_USER}" ] && [ -n "${KEYCLOAK_PASSWORD}" ]; then
  /opt/jboss/keycloak/bin/add-user-keycloak.sh --user "${KEYCLOAK_USER}" --password "${KEYCLOAK_PASSWORD}"
fi

# Default to H2 if DB type not detected
if [ -z "${DB_VENDOR}" ]; then
  export DB_VENDOR="h2"
fi

# Set DB name
DB_VENDOR=$(echo "${DB_VENDOR}" | tr '[:upper:]' '[:lower:]')
case "${DB_VENDOR}" in
  h2)
    DB_NAME="Embedded H2" ;;
  mariadb)
    DB_NAME="MariaDB" ;;
  mysql)
    DB_NAME="MySQL" ;;
  postgres)
    DB_NAME="PostgreSQL" ;;
  *)
    echo "Unknown DB vendor ${DB_VENDOR}"
    exit 1
esac
echo "Using ${DB_NAME} database"

if [ "${DB_VENDOR}" != "h2" ]; then
  /bin/sh /opt/jboss/tools/databases/change-database.sh "${DB_VENDOR}"
fi

if [ -z "${HOSTNAME}" ]; then
  HOSTNAME="localhost"
fi

SYS_PROPS="-Dkeycloak.hostname.provider=fixed \
  -Dkeycloak.hostname.fixed.hostname=${HOSTNAME} \
  -Dkeycloak.hostname.fixed.httpPort=8080"

exec /opt/jboss/keycloak/bin/standalone.sh "${SYS_PROPS}" "$@"
exit $?
