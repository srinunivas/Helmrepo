FROM {{deps.mqadvancedServer.name}}

COPY ./conf/20-config.mqsc /etc/mqm/
