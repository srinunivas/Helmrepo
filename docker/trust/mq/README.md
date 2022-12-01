# IBM MQ Docker Image for Trust

A Trust IBM MQ image for FSK based on 
[third-parties/mq_webspheremq](https://portus.jenkins-deploy.fircosoft.net/repositories/200)

## Portus Link

  - Trust Namespace: https://portus.jenkins-deploy.fircosoft.net/namespaces/25
  - Trust IBM MQ Repository: https://portus.jenkins-deploy.fircosoft.net/repositories/266

## Usage

```sh
docker run \
  --interactive \
  --publish 1414:1414 \
  --publish 9443:9443 \
  --publish 9157:9157 \
  jenkins-deploy.fircosoft.net/trust/mq:<tag>
```

This command starts a Webphere MQ server with default:
  - queue manager `FSKQM`
  - channel `FSKQM_CHL`
  - queues `IN`, `OUT`, `ALERT` and `DECISION`.

The *IBM MQ Console* application is available on https://localhost:9443/ibmmq/console/.
Use `admin` as username and `hello001` as password.

To start Websphere MQ with a custom queues, mount your configuration to `/etc/mqm/20-config.mqsc`:

```sh
docker run \
  --interactive \
  --volume /path/to/my/config.mqsc:/etc/mqm/20-config.mqsc \
  jenkins-deploy.fircosoft.net/trust/mq:<tag>
```

See [official Webphere MQ documentation](https://github.com/ibm-messaging/mq-container/blob/master/docs/usage.md)
for more usage information.

## Environment Variables

| Variable            | Default value | Description                                                               |
|---------------------|---------------|---------------------------------------------------------------------------|
| `MQ_QMGR_NAME`      | `FSKQM`       | Name of the Queue Manager to create at the startup                        |
| `MQ_ADMIN_PASSWORD` | `hello001`    | Password of the `admin` user. Must be at least 8 characters long          |
| `MQ_ENABLE_METRICS` | `false`       | Set this to `true` to generate Prometheus metrics for your Queue Manager  |
| `MQ_DEV`            | `false`       | Set `true` to enable development mode                                     |

See the official [IBM Websphere MQ Docker documentation](https://github.com/ibm-messaging/mq-container)
and [Default Docker configuration](https://github.com/ibm-messaging/mq-container/blob/master/docs/developer-config.md)
for more information about environment variables.

## Versioning

This repository follows the versioning of IBM Webphere MQ.

## Contribute

Submit a Pull Request with your changes following the official
[Docker Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
