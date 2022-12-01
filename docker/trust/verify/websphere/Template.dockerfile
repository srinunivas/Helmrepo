FROM {{deps.websphere.name}}

ARG TRUST_VERIFY_HOME="/opt/trust/verify"

# The admin console user password
ARG ADMIN_CONSOLE_PASSWORD="hello001"

ENV TRUST_DB_INSTANCE="Developer"
ENV TRUST_APP_VERSION="{{version}}"
ENV CONTEXT_NAME="trust"
ENV IBMCOM_WEBSPHERE_HOME="/opt/IBM/WebSphere/AppServer"

# Use basic logging mode is plain text format
ENV ENABLE_BASIC_LOGGING=true

# Server setup
COPY --chown=was:root entrypoint.sh $TRUST_VERIFY_HOME/
COPY --chown=was:root jython/*.py /work/config/

ADD --chown=was:root {{deps.verify.uri}} /work/config/app.war
ADD --chown=was:root http://dev-nexus.fircosoft.net/service/local/repositories/central/content/com/oracle/ojdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar $IBMCOM_WEBSPHERE_HOME/lib/ojdbc8-19.3.0.0.jar
ADD --chown=was:root http://dev-nexus.fircosoft.net/content/sites/site-3rd-parties/microsoft/mssql-jdbc/8.4.1/mssql-jdbc-8.4.1.jre8.jar $IBMCOM_WEBSPHERE_HOME/lib/mssql-jdbc-8.4.1.jre8.jar

RUN echo $ADMIN_CONSOLE_PASSWORD > /tmp/PASSWORD

HEALTHCHECK --interval=30s --timeout=15m --retries=30 \
  CMD curl -f http://localhost:9080/$CONTEXT_NAME || exit 1

ENTRYPOINT ["/opt/trust/verify/entrypoint.sh"]
