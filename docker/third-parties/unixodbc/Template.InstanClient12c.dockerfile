FROM centos:7

#
# Install unixODBC and Oracle Client
#
RUN yum update -y \
  && yum install -y epel-release \
  && yum install -y \
    libaio-0.3.109-13.el7.{i686,x86_64} \
    unixODBC-2.3.1-14.el7.{i686,x86_64} \
    http://dev-nexus.fircosoft.net/content/sites/external/release/Linux/x86_64/oracle-instantclient-sqlplus/12.1.0.2.0-1/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm \
    http://dev-nexus.fircosoft.net/content/sites/external/release/Linux/x86_64/oracle-instantclient-basic/12.1.0.2.0-1/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm \
    http://dev-nexus.fircosoft.net/content/sites/external/release/Linux/x86_64/oracle-instantclient-odbc/12.1.0.2.0-1/oracle-instantclient12.1-odbc-12.1.0.2.0-1.x86_64.rpm \
    http://dev-nexus.fircosoft.net/content/sites/external/release/Linux/i386/oracle-instantclient-basic/12.1.0.2.0-1/oracle-instantclient12.1-basic-12.1.0.2.0-1.i386.rpm \
    http://dev-nexus.fircosoft.net/content/sites/external/release/Linux/i386/oracle-instantclient-odbc/12.1.0.2.0-1/oracle-instantclient12.1-odbc-12.1.0.2.0-1.i386.rpm \
  && yum clean all

#
# Configure Oracle ODBC Driver Client
#
RUN ln -s /usr/lib/oracle/12.1/client/lib/libclntsh.so.12.1 /usr/lib/oracle/12.1/client/lib/libclntsh.so.12 \
  && ln -s /usr/lib/oracle/12.1/client/lib/libclntsh.so.12.1 /usr/lib/oracle/12.1/client/lib/libclntsh.so \
  && ln -s /usr/lib/libodbc.so /usr/lib/libodbc.so.1 \
  && chmod +x /usr/lib/oracle/12.1/client/lib/libsqora.so.12.1

ENV ORACLE_HOME=/usr/lib/oracle/12.1/client \
    PATH="/usr/lib/oracle/12.1/client/bin:/usr/lib/oracle/12.1/client64/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/lib/oracle/12.1/client/lib:/usr/lib/oracle/12.1/client64/lib:/usr/lib:$LD_LIBRARY_PATH" \
    NLS_LANG=AMERICAN_AMERICA.AL32UTF8

RUN mkdir -p /usr/lib/oracle/12.1/client/network/admin
COPY odbcinst.12c.ini /etc/odbcinst.ini

ARG UNIXODBC_IMAGE_HOME="/opt/third-parties/unixodbc-oracle-client"

RUN ln -s /opt/third-parties/unixodbc-oracle-client/entrypoint.sh /usr/bin/start.sh

ENV PATH="$UNIXODBC_IMAGE_HOME:$PATH"
ENV TNSNAME_PORT=1521

COPY entrypoint.sh $UNIXODBC_IMAGE_HOME/

RUN useradd -ms /bin/bash firco \
  && usermod -aG root firco

WORKDIR $UNIXODBC_IMAGE_HOME

USER firco

ENTRYPOINT ["/opt/third-parties/unixodbc-oracle-client/entrypoint.sh"]
