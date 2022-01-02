FROM jboss/keycloak:15.0.2

USER root

# parses ecs metadata
RUN microdnf update -y && \
    microdnf install -y jq && \
    microdnf clean all

USER jboss

# Setup keystore
RUN /opt/jboss/tools/x509.sh

# Customize entrypoint and config
# NOTE: jboss/keycloak includes JDBC drivers.
COPY docker-entrypoint.sh /opt/jboss/tools/docker-entrypoint.sh
COPY standalone-ha.xml /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml
# https://www.keycloak.org/docs/latest/server_installation/index.html#profiles
COPY profile.properties /opt/jboss/keycloak/standalone/configuration/profile.properties

# Install custom themes
RUN mkdir -p /opt/jboss/keycloak/themes
COPY themes/ /opt/jboss/keycloak/themes/

# Clustering
ENV JGROUPS_DISCOVERY_PROTOCOL JDBC_PING
ENV JGROUPS_DISCOVERY_PROPERTIES datasource_jndi_name=java:jboss/datasources/KeycloakDS
# https://github.com/keycloak/keycloak-containers/blob/master/server/README.md#replication-and-fail-over
ENV CACHE_OWNERS_COUNT 2
ENV CACHE_OWNERS_AUTH_SESSIONS_COUNT 2
# https://github.com/keycloak/keycloak-containers/blob/master/server/README.md#enabling-proxy-address-forwarding
ENV PROXY_ADDRESS_FORWARDING true

EXPOSE 7600
CMD ["-b", "0.0.0.0", "--server-config", "standalone-ha.xml"]
