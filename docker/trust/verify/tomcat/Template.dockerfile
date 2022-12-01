FROM {{deps.tomcat.name}}

ARG TRUST_VERIFY_HOME="/opt/trust/verify"
ENV TRUST_DB_INSTANCE="Developer"
ENV CONTEXT_NAME="trust"

USER root

# Install curl
RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update \
  && apt-get install -y curl \
  && rm -rf /var/lib/apt/lists/*

# Generate RSA certificat
RUN openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365000 \
  -keyout $CATALINA_HOME/conf/fircosoft.key \
  -out $CATALINA_HOME/conf/fircosoft.crt \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Accuity/OU=Fircosoft/CN=fircosoft.net"

# Tomcat Setup
COPY config/entrypoint.sh $TRUST_VERIFY_HOME/
COPY config/server*.xml $CATALINA_HOME/conf/

ADD http://dev-nexus.fircosoft.net/service/local/repositories/central/content/com/oracle/ojdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar $CATALINA_HOME/lib/ojdbc8-19.3.0.0.jar
ADD http://dev-nexus.fircosoft.net/content/sites/site-3rd-parties/microsoft/mssql-jdbc/8.4.1/mssql-jdbc-8.4.1.jre11.jar $CATALINA_HOME/lib/mssql-jdbc-8.4.1.jre11.jar
ADD http://dev-nexus.fircosoft.net/content/sites/site-3rd-parties/microsoft/mssql-jdbc/8.4.1/mssql-jdbc-8.4.1.jre8.jar $CATALINA_HOME/lib/mssql-jdbc-8.4.1.jre8.jar
ADD config/catalina.context.xml ${CATALINA_HOME}/conf/context.xml
ADD config/error.html ${CATALINA_HOME}/webapps/error.html
ADD {{deps.verify.uri}} $CATALINA_HOME/webapps/app.war

RUN chmod 644 $CATALINA_HOME/lib/*.jar \
  && chmod 655 $TRUST_VERIFY_HOME/entrypoint.sh \
  && chown -R tomcat $CATALINA_HOME/conf/server.xml \
                     $CATALINA_HOME/webapps/ \
                     $CATALINA_HOME/conf/fircosoft*

# Logged as tomcat
USER tomcat

HEALTHCHECK --interval=2s --timeout=5s --retries=10 \
  CMD curl -f http://localhost:8080/$CONTEXT_NAME || exit 1

ENTRYPOINT ["/opt/trust/verify/entrypoint.sh"]
