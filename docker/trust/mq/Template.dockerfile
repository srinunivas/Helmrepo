FROM {{deps.webspheremq.name}}

# Environment documentation: https://github.com/ibm-messaging/mq-container
ENV LICENSE=accept
ENV MQ_ENABLE_METRICS=false
ENV MQ_ADMIN_PASSWORD=hello001
ENV MQ_QMGR_NAME=FSKQM
ENV MQ_DEV=false

COPY conf/20-config.mqsc /etc/mqm/

HEALTHCHECK --interval=5s --timeout=30s --retries=5 \
  CMD curl -fk https://localhost:9443/ibmmq/console/ || exit 1
