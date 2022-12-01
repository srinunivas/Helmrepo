# Pull base image
# ---------------
FROM {{deps.os.name}} as base


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


# Install usefull components
# ----------
USER root
RUN yum update -y 
RUN yum install -y \
  java-11-openjdk
COPY {{deps.init.path}} /usr/bin/dumb-init
RUN chmod 755 /usr/bin/dumb-init


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV DB_VENDOR "oracle"
ENV DB_DRIVER ""
ENV DB_HOST ""
ENV DB_PORT ""
ENV DB_NAME ""
ENV DB_CONNECTION_STRING ""
ENV DB_USER ""
ENV DB_PASSWORD ""
ENV PRODUCT_VERSION={{version}}
ENV FRONTEND_VERSION={{deps.deployment-console.env}}-{{deps.deployment-console.version}}.p{{deps.deployment-console.push}}
ENV ORACLE_JDBC_VERSION={{deps.ojdbc-ojdbc8.asset}}-{{deps.ojdbc-ojdbc8.version}}


# Install Oracle client
# ----------
USER root
ENV ORACLE_HOME=/usr/lib/oracle/{{deps.instantclient_basic_x86_64.version}}/client64
COPY ["{{deps.instantclient_basic_x86_64.path}}", "{{deps.instantclient_sqlplus_x86_64.path}}", "/tmp/"]
RUN yum -y localinstall /tmp/*.rpm


# Install files
# ----------
USER root
RUN mkdir -p /opt/continuity
ADD {{deps.deployment-console.uri}} /opt/continuity/
ADD {{deps.workflow.uri}} /opt/continuity/
ADD {{deps.ojdbc-ojdbc8.uri}} /opt/continuity/
COPY config/entrypoint.sh /opt/continuity/
COPY config/checkContinuityDeployment.sh /opt/continuity/
COPY config/execCustomSqlScripts.sh /opt/continuity/
RUN chmod -R 644 /opt/continuity/*.jar
RUN chmod -R 644 /opt/continuity/*.jar
RUN chmod -R 755 /opt/continuity/*.sh


# Set path for oracle
# ----------
ENV PATH=$ORACLE_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH


# Set volume for custom sql scripts
# ----------
ENV CUSTOM_SQL_SCRIPTS /opt/continuity/sql_scripts
VOLUME ["/opt/continuity/sql_scripts"]


# Deploy continuity into the db
# ----------
ENTRYPOINT [ "/usr/bin/dumb-init", "/opt/continuity/entrypoint.sh" ]
