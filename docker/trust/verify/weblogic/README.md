# Firco Trust Docker Image for WebLogic

A Firco Trust images based on official WebLogic.

## Features

- Use Oracle JDK
- Healthcheck

## Portus Links

  - Trust Namespace: https://portus.jenkins-deploy.fircosoft.net/namespaces/25
  - Trust Verify Repository: https://portus.jenkins-deploy.fircosoft.net/repositories/255

## Usage

```sh
docker run -i \
  -e CONTEXT_NAME=trust \
  -e TRUST_DB_HOST=<db-ip> \
  -e TRUST_DB_PORT=<db-port> \
  -e TRUST_DB_NAME=<db-name> \
  -e TRUST_DB_USER=<db-user> \
  -e TRUST_DB_PWD=<db-pwd> \
  -e TRUST_DB_DRIVER=<db-driver> \
  -p 7001:7001 \
  -p 7002:7002 \
  -p 9002:9002 \
  jenkins-deploy.fircosoft.net/trust/verify:<tag>
```

The application is available on:

- https://localhost:7002/trust
- http://localhost:7001/trust

Open the WebLogic Admin Console by using https://localhost:9002/console.
The admin username is `trust` and the password is `hello001`.

## Environment Variables

| Variable          | Default | Description                                                         |
|-------------------|---------|---------------------------------------------------------------------|
| `CONTEXT_NAME`    | `trust` | Application context name                                            |
| `TRUST_DB_DRIVER` |         | Database driver. Allow values: `oracle12`, `oracle19`, `sqlserver`  |
| `TRUST_DB_HOST`   |         | Database host                                                       |
| `TRUST_DB_PORT`   |         | Database port                                                       |
| `TRUST_DB_NAME`   |         | Database name                                                       |
| `TRUST_DB_USER`   |         | Database username                                                   |
| `TRUST_DB_PWD`    |         | Database password                                                   |

> **Note** that if you're trying to use Trust Verify with Oracle 19c which
  exposes an instance through a service name, must use `TRUST_DB_DRIVER=oracle19`

## Contribute

Submit a Pull Request with your changes following the official
[Docker Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
