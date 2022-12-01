FROM {{deps.unixodbc.name}}

ARG TRUST_FSK_HOME="/opt/fircosoft/trust/fsk"
ENV PATH="$TRUST_FSK_HOME:$PATH"
ENV LD_LIBRARY_PATH="/opt/mqm/lib:$LD_LIBRARY_PATH"
ENV WEBSPHERE_MQ_VERSION="7.5.0.2"
ENV PRESET_ENV="false"

USER root

RUN mkdir /root/mq \
  && cd /root/mq \
  && curl -s http://dev-nexus.fircosoft.net/content/sites/external/release/Linux/i386/ibm-websphere-mq/${WEBSPHERE_MQ_VERSION}/WS_MQ_CLIENT_LIN_X86_32_${WEBSPHERE_MQ_VERSION}.tar.gz \
        | tar xzv \
  && echo 1 | ./mqlicense.sh \
  && rpm -ivh *.rpm \
  && cd /root \
  && rm -Rf mq

WORKDIR $TRUST_FSK_HOME

RUN curl -s {{deps.fsk.uri}} | tar xzv
COPY entrypoint.sh /opt/fircosoft/trust/
RUN chmod +x /opt/fircosoft/trust/entrypoint.sh

USER firco

ENTRYPOINT ["/opt/fircosoft/trust/entrypoint.sh"]
