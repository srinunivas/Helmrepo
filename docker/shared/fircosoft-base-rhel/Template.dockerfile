FROM {{deps.base.name}}
LABEL MAINTAINER="DevOps <devops@accuity.com>"

RUN (subscription-manager clean \
 && subscription-manager register --activationkey=rhel1 --org=4912799) || true

RUN yum group install -y "Development Tools" \
 && yum install -y llvm-toolset gcc-gfortran libstdc++.i686 libaio.i686

RUN echo "**** Installing Java 11" \
 && yum install -y java-11-openjdk \
 && JAVA_11=$(alternatives --display java | grep 'family java-11-openjdk' | cut -d' ' -f1) \
 && alternatives --set java $JAVA_11

COPY ["{{deps.libnsl.path}}", "{{deps.instantclient_basic.path}}", "{{deps.instantclient_sqlplus.path}}", "{{deps.instantclient_odbc.path}}", "/tmp/"]
RUN rpm -ivh /tmp/*.rpm

RUN echo "**** Installing MQ Client 9.0.0.4" \
 && mkdir -p /opt/mq-client
COPY {{deps.mq_client.installpath}} /opt/mq-client
RUN /opt/mq-client/bin/dspmqver

RUN echo "export PATH=/opt/mq-client/bin:/usr/lib/oracle/19.6/client/bin:${PATH}" >> /etc/profile \
 && echo "export LD_LIBRARY_PATH=/opt/mq-client/lib:/opt/mq-client/lib64:/usr/lib/oracle/19.6/client/lib:${LD_LIBRARY_PATH}" >> /etc/profile

EXPOSE 22/tcp 80/tcp 1414/tcp

RUN subscription-manager unregister
