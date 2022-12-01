# IBM MQ clone image for Fircosoft

This is a clone of the official image IBM [MQ image](https://hub.docker.com/r/ibmcom/mq)
created to perform a cache on Fircosoft Portus repository.

**No change have been made on this image**

## Usage

```sh
docker run \
  --env LICENSE=accept \
  --env MQ_QMGR_NAME=QM1 \
  --publish 1414:1414 \
  --publish 9443:9443 \
  --detach \
  jenkins-deploy.fircosoft.net/third-parties/ibmcom/mq:9.2.1.0-r1
```

**For complete usage and documentation, please check https://github.com/ibm-messaging/mq-container/blob/master/docs/usage.md**

**References**

- Official Docker Hub page: https://hub.docker.com/r/ibmcom/mq
- Official Usage Documentation: https://github.com/ibm-messaging/mq-container/blob/master/docs/usage.md
