FROM centos:7

ENV CONTINUITY_HOME="/opt/fircosoft/continuity"

RUN yum install -y \
        glibc.i686 glibc.x86_64 \
        gzip \
        iputils \
        libstdc++.i686 libstdc++.x86_64 \
        tar \
        libaio.i686 libaio.x86_64

ADD http://dev-nexus.fircosoft.net/content/repositories/site-3rd-parties/oracle/linux/instantclient/oracle-instantclient12.2-basic-12.2.0.1.0-1.i386.rpm /tmp
RUN rpm -i /tmp/oracle-instantclient12.2-basic-12.2.0.1.0-1.i386.rpm

RUN curl -s http://dev-nexus.fircosoft.net/service/local/repositories/site-3rd-parties/content/ibm-mqseries/Linux/9.1.3/x64/IBM_MQ_9.1.3_LINUX_X86-64/IBM_MQ_9.1.3_LINUX_X86-64.tar.gz | tar xzvC /tmp
RUN cd /tmp/MQServer && ./mqlicense.sh -accept && rpm -ivh \
 MQSeriesClient* MQSeriesRuntime*
RUN /opt/mqm/bin/setmqinst -i -p /opt/mqm 

ENV MQ_HOME="/opt/mqm"
ENV ORACLE_HOME=/usr/lib/oracle/12.2/client
ENV LD_LIBRARY_PATH=$ORACLE_HOME/lib:/opt/mqm/lib

RUN ln -sf libclntsh.so.12.1 $ORACLE_HOME/lib/libclntsh.so
RUN rm -rf /tmp/*


RUN mkdir -p $CONTINUITY_HOME/backend

COPY entrypoint.sh /opt/fircosoft/continuity/

RUN chmod +x /opt/fircosoft/continuity/entrypoint.sh

# Install coreengine Component
RUN curl -s {{deps.coreengine.uri}} | tar xzvC $CONTINUITY_HOME/backend

# Install Requester Component
RUN curl -s {{deps.requester.uri}} | tar xzvC $CONTINUITY_HOME/backend

#Install FilterEngine Component
RUN curl -s {{deps.filter.uri}} | tar xzvC ${CONTINUITY_HOME}/backend/FilterEngine
RUN echo "fircoof         3005/tcp        #Firco Filter" >> /etc/services

WORKDIR $CONTINUITY_HOME/backend

ENTRYPOINT [ "/opt/fircosoft/continuity/entrypoint.sh" ]