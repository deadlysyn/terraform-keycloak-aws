#!/bin/sh

HOST="${1?Must provide target DB hostname or address}"
FILE="${HOST}-$(date +%s).sql"

for i in nc pg_dump; do
  command -v ${i} >/dev/null || {
    echo "ERROR: Can't find ${i} in PATH"
    exit 1
    }
done

if nc -zw5 "${HOST}" 5432 >/dev/null 2>&1; then
  echo "Exporting ${FILE}..."
  pg_dump -O -C -c \
    -h "${HOST}" \
    -d keycloak \
    -U keycloak \
    -W > "${FILE}"
else
  echo "ERROR: Can't reach ${HOST}:5432"
fi
