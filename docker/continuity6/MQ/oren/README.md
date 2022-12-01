
## Running

    docker run \
       --env LICENSE=accept \
       --env MQ_QMGR_NAME=OREN_QM \
       --publish 1414:1414 \
       --publish 9443:9443 \
       --publish 9157:9157 \ 
       --name mq-oren-mtls  \ 
       jenkins-deploy.fircosoft.net/continuity6/mq-oren-mtls:9.1.2.0

## Console access

    url : https://<host>:9443/ibmmq/console/login.html
    user : admin
    password : passw0rd