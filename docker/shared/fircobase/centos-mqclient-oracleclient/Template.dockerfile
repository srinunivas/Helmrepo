# Pull base image
# ---------------
FROM {{deps.base.name}} as base


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


## Update base
## ----------
USER root
RUN yum update -y
RUN yum install -y \
    libaio.i686 \
    glibc.i686


# Copy reference files to trigger rebuild upon change
# ----------
USER root
COPY {{imageDataPath}} /imageData


# Install MQ client
# ----------
USER root
ENV ORACLE_HOME=/usr/lib/oracle/{{deps.instantclient_basic_i386.version}}/client
COPY ["{{deps.instantclient_basic_i386.path}}", "{{deps.instantclient_sqlplus_i386.path}}", "/tmp/"]
RUN rpm -ivh /tmp/*.rpm


# Start as admin user
# ----------
USER admin
WORKDIR $ADMIN_HOME
ENV PATH=$ORACLE_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH


# Start container command
# ----------
CMD [ "/bin/bash" ]