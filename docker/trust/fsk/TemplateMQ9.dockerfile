FROM {{deps.unixodbc.name}}

ARG TRUST_FSK_HOME="/opt/fircosoft/trust/fsk"
ENV PATH="$TRUST_FSK_HOME:$PATH"
ENV LD_LIBRARY_PATH="/opt/mqm/lib:$LD_LIBRARY_PATH"
ENV WEBSPHERE_MQ_VERSION="9.2.0.1"
ENV PRESET_ENV="false"

USER root
RUN useradd -ms /bin/bash mqm \
  && usermod -aG mqm mqm

WORKDIR /opt/mqm
RUN curl -s {{deps.mqclient.uri}} | tar xzv
RUN rm -rf bin gskit8 java lap lib64 inc msg samp swidtag
RUN chown -R mqm:mqm /opt/mqm

WORKDIR $TRUST_FSK_HOME
RUN curl -s {{deps.fsk.uri}} | tar xzv
COPY entrypoint.sh /opt/fircosoft/trust/
RUN chmod +x /opt/fircosoft/trust/entrypoint.sh

USER firco
ENTRYPOINT ["/opt/fircosoft/trust/entrypoint.sh"]
