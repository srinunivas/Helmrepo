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


# Copy reference files to trigger rebuild upon change
# ----------
USER root
COPY {{imageDataPath}} /imageData


# Install MQ client
# ----------
USER root
ENV MQ_HOME="/opt/mqm"
RUN curl -s {{deps.mq_client.uri}} | tar xzvC /tmp
RUN cd /tmp/MQServer && ./mqlicense.sh -accept && rpm -ivh MQSeriesClient* MQSeriesRuntime*
RUN $MQ_HOME/bin/setmqinst -i -p $MQ_HOME 
RUN rm -rf /tmp/*


# Start as admin user
# ----------
USER admin
WORKDIR $ADMIN_HOME
ENV PATH=$MQ_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$MQ_HOME/lib:$LD_LIBRARY_PATH



# Start container command
# ----------
CMD [ "/bin/bash" ]