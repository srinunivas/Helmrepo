FROM quay.io/keycloak/keycloak:{{version}}

USER root

ENV USERS_NUMBER $USERS_NUMBER
ENV SP_URL $SP_URL

ENV KEYCLOAK_USER admin
ENV KEYCLOAK_PASSWORD admin
ENV DB_VENDOR h2
ENV KEYCLOAK_IMPORT /tmp/keycloak-config-generated.json

COPY  keycloak_entrypoint.sh /tmp/keycloak_entrypoint.sh
COPY keycloak-template.json /tmp/keycloak-template.json

ENTRYPOINT ["/tmp/keycloak_entrypoint.sh","$USERS_NUMBER","$SP_URL"]
