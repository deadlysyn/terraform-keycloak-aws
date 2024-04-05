##################################################
# Step 1 - Build an optimized image
##################################################
FROM quay.io/keycloak/keycloak:24.0.1 as builder

# These options can be modified to produce a different
# optimized build.
#
# See  https://www.keycloak.org/server/containers
# for more details.
ENV KC_METRICS_ENABLED=true
ENV KC_HEALTH_ENABLED=true
ENV KC_FEATURES=preview
ENV KC_DB=postgres

# https://github.com/keycloak/keycloak/discussions/10274
# https://stackoverflow.com/questions/73049385/keycloak18-index-page-resource-not-found
# This no longer works cleanly, neither does passing --http-relative-path=/auth
#ENV KC_HTTP_RELATIVE_PATH=/auth

# # Clustering
# (https://gist.github.com/xgp/768eea11f92806b9c83f95902f7f8f80)
COPY ./cache-ispn-jdbc-ping.xml /opt/keycloak/conf/cache-ispn-jdbc-ping.xml
ENV KC_CACHE_CONFIG_FILE=cache-ispn-jdbc-ping.xml

# Install custom themes
COPY themes/ /opt/keycloak/themes

# Create an optimized build
RUN /opt/keycloak/bin/kc.sh build

##################################################
# Step 2 - Add required dependencies
# https://www.keycloak.org/server/containers
##################################################
FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
RUN mkdir -p /mnt/rootfs

# curl and jq used to parse ecs metadata
RUN dnf update -y && \
  dnf install --installroot /mnt/rootfs curl jq --releasever 9 --setopt install_weak_deps=false --nodocs -y && \
  dnf --installroot /mnt/rootfs clean all && \
  rpm --root /mnt/rootfs -e --nodeps setup

###################################################################
# Step 3 - Copy optimized build and dependencies into running image
###################################################################
FROM quay.io/keycloak/keycloak:24.0.1

USER root
COPY --from=ubi-micro-build /mnt/rootfs /
USER keycloak
COPY --from=builder /opt/keycloak /opt/keycloak

WORKDIR /opt/keycloak

# Allows server to start in prod mode. Actual certs provided by ALB.
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
# Customize entrypoint and config
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Paranoia: Keycloak is not vulnerable to CVE-2021-44228
# https://github.com/keycloak/keycloak-containers/issues/344
# https://logging.apache.org/log4j/log4j-2.14.1/manual/configuration.html#SystemProperties
ENV FORMAT_MESSAGES_PATTERN_DISABLE_LOOKUPS true

# Port 7800 is used by JDBC_PING by default
EXPOSE 7800
ENTRYPOINT ["/docker-entrypoint.sh"]
