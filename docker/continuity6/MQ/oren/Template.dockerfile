FROM {{deps.mqadvancedServer.name}}

COPY custom-config.mqsc /etc/mqm/
RUN mkdir /etc/mqm/ssl
COPY ssl/ /etc/mqm/ssl

USER root
RUN chmod -R a+w /etc/mqm/ssl

USER mqm
RUN runmqckm -cert -add -db /etc/mqm/ssl/key.kdb -pw secret -label ibmwebspheremqmqm -file /etc/mqm/ssl/oren.pem
