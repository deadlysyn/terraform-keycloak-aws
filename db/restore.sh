#!/bin/sh

HOST="${1?Must provide target DB hostname or address}"
FILE="${2?Must provide filename to restore}"

for i in nc psql; do
  command -v ${i} >/dev/null || {
    echo "ERROR: Can't find ${i} in PATH"
    exit 1
    }
done

if [ -e "${FILE}" ]; then
  if nc -zw5 "${HOST}" 5432 >/dev/null 2>&1; then
    psql \
      -h "${HOST}" \
      -d postgres \
      -U keycloak \
      -W < "${FILE}"
  else
     echo "ERROR: Can't reach ${HOST}:5432"
  fi
else
  echo "ERROR: Can't find ${FILE}"
fi
