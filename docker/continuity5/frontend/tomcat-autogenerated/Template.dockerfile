# Pull base image
# ---------------
FROM {{deps.tomcat.name}} as base


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


# Install usefull components
# ----------
USER root
RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update \
  && apt-get install -y \
    curl \
    iputils-ping \
    libaio1  \
    vim \
  && rm -rf /var/lib/apt/lists/*
RUN apt-get update


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV DB_VENDOR ""
ENV DB_DRIVER ""
ENV DB_URL ""
ENV DB_USER ""
ENV DB_PASSWORD ""
ENV PRODUCT_VERSION={{version}}
ENV FRONTEND_VERSION={{deps.platform.env}}-{{deps.platform.version}}.p{{deps.platform.push}}
ENV ORACLE_JDBC_VERSION={{deps.ojdbc-ojdbc8.asset}}-{{deps.ojdbc-ojdbc8.version}}
ENV MSSQL_JDBC_VERSION={{deps.mssql-jdbc.asset}}-{{deps.mssql-jdbc.version}}
ENV CONTEXT_NAME="continuity"


# Generate RSA certificat
# ----------
USER root 
RUN openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365000 \
  -keyout $CATALINA_HOME/conf/fircosoft.key \
  -out $CATALINA_HOME/conf/fircosoft.crt \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Accuity/OU=Fircosoft/CN=fircosoft.net"
RUN chown -R tomcat:tomcat $CATALINA_HOME/


# Copy platform war file inside tomcat
# ----------
USER tomcat
RUN echo Copying {{deps.platform.uri}} in $CATALINA_HOME/webapps
ADD --chown=tomcat {{deps.platform.uri}} $CATALINA_HOME/webapps/$CONTEXT_NAME.war
ADD --chown=tomcat {{deps.ojdbc-ojdbc8.uri}} $CATALINA_HOME/lib/
ADD --chown=tomcat {{deps.mssql-jdbc.uri}} $CATALINA_HOME/lib/
COPY --chown=tomcat config/server.xml $CATALINA_HOME/conf
COPY --chown=tomcat config/context.xml $CATALINA_HOME/conf
COPY --chown=tomcat config/setenv.sh $CATALINA_HOME/bin
COPY --chown=tomcat config/error.html ${CATALINA_HOME}/webapps


# Set path for oracle
# ----------
ENV PATH=$ORACLE_HOME/bin:$PATH
ENV PATH=/opt/mssql-tools/bin:$PATH
ENV LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH


# Health check
# ----------
HEALTHCHECK --interval=2s --timeout=5s --retries=10 \
  CMD curl -f http://localhost:8080/$CONTEXT_NAME || exit 1


# Start the server
# ----------
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]