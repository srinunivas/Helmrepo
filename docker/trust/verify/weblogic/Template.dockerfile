FROM {{deps.weblogic.name}}

ENV TRUST_APP_VERSION="{{version}}"
ENV TRUST_DB_INSTANCE="Developer"
ENV CONTEXT_NAME="trust"

ENV DOMAIN_NAME="fircosoft"
ENV DOMAIN_USERNAME="trust"
ENV DOMAIN_PASSWORD="hello001"

ENV WEBLOGIC_HOME="/u01/oracle"
ENV WEBLOGIC_WEBAPPS_DIR="$WEBLOGIC_HOME/webapps"
ENV WEBLOGIC_SERVER_DIR="$WEBLOGIC_HOME/wlserver/server"

ADD --chown=oracle:oracle http://dev-nexus.fircosoft.net/service/local/repositories/central/content/com/oracle/ojdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar $WEBLOGIC_SERVER_DIR/lib/ojdbc8-19.3.0.0.jar
ADD --chown=oracle:oracle http://dev-nexus.fircosoft.net/content/sites/site-3rd-parties/microsoft/mssql-jdbc/8.4.1/mssql-jdbc-8.4.1.jre8.jar $WEBLOGIC_SERVER_DIR/lib/mssql-jdbc-8.4.1.jre8.jar
ADD --chown=oracle:oracle {{deps.verify.uri}} $WEBLOGIC_WEBAPPS_DIR/app.war

COPY scripts/* $WEBLOGIC_HOME/

HEALTHCHECK --interval=3s --timeout=60s --retries=10 \
  CMD curl -f http://localhost:7001/$CONTEXT_NAME || exit 1

CMD '/u01/oracle/start.sh'
