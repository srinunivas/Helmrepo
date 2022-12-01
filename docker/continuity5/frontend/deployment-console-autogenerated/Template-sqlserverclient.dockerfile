# Pull base image
# ---------------
FROM {{deps.os.name}} as base


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


# Install usefull components
# ----------
USER root
RUN curl https://packages.microsoft.com/config/rhel/8/prod.repo > /etc/yum.repos.d/msprod.repo
RUN yum update -y 
RUN yum install -y \
  java-11-openjdk
COPY {{deps.init.path}} /usr/bin/dumb-init
RUN chmod 755 /usr/bin/dumb-init


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV DB_VENDOR "microsoft"
ENV DB_DRIVER ""
ENV DB_HOST ""
ENV DB_PORT ""
ENV DB_NAME ""
ENV DB_CONNECTION_STRING ""
ENV DB_USER ""
ENV DB_PASSWORD ""
ENV PRODUCT_VERSION={{version}}
ENV FRONTEND_VERSION={{deps.deployment-console.env}}-{{deps.deployment-console.version}}.p{{deps.deployment-console.push}}
ENV MSSQL_JDBC_VERSION={{deps.mssql-jdbc.asset}}-{{deps.mssql-jdbc.version}}


# Install Oracle client
# ----------
USER root
RUN yum --showduplicates list mssql-tools | expand
RUN ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive yum install -y mssql-tools-17.8.1.1-1


# Install files
# ----------
USER root
RUN mkdir -p /opt/continuity
ADD {{deps.deployment-console.uri}} /opt/continuity/
ADD {{deps.workflow.uri}} /opt/continuity/
ADD {{deps.mssql-jdbc.uri}} /opt/continuity/
COPY config/entrypoint.sh /opt/continuity/
COPY config/checkContinuityDeployment.sh /opt/continuity/
COPY config/execCustomSqlScripts.sh /opt/continuity/
RUN chmod -R 644 /opt/continuity/*.jar
RUN chmod -R 644 /opt/continuity/*.jar
RUN chmod -R 755 /opt/continuity/*.sh


# Set path for mssql
# ----------
ENV PATH=/opt/mssql-tools/bin:$PATH


# Set volume for custom sql scripts
# ----------
ENV CUSTOM_SQL_SCRIPTS /opt/continuity/sql_scripts
VOLUME ["/opt/continuity/sql_scripts"]


# Start the server
# ----------
ENTRYPOINT [ "/usr/bin/dumb-init", "/opt/continuity/entrypoint.sh" ]
