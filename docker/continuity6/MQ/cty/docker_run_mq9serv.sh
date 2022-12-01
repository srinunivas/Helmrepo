docker run \
  --env LICENSE=accept \
  --env MQ_QMGR_NAME=QM1 \
  --publish 1414:1414 \
  --publish 9443:9443 \
  --detach \
jenkins-deploy.fircosoft.net/continuity6/mq-cty:9.1.2.0