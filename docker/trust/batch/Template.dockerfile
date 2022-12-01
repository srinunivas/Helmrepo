FROM {{deps.unixodbc.name}}

ENV TRUST_BATCH_HOME="/opt/fircosoft/trust/batch"
ENV PATH="$TRUST_BATCH_HOME/bin:$PATH"
ENV LD_LIBRARY_PATH="/opt/mqm/lib:$LD_LIBRARY_PATH"
ENV PRESET_ENV="false"

USER root

WORKDIR $TRUST_BATCH_HOME

RUN curl -s {{deps.batch.uri}} | tar xzv
COPY entrypoint.sh /opt/fircosoft/trust/
RUN chmod +x /opt/fircosoft/trust/entrypoint.sh

USER firco

ENTRYPOINT ["/opt/fircosoft/trust/entrypoint.sh"]
