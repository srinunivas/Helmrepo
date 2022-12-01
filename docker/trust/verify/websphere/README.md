# Firco Trust Docker Image for WebSphere

A Firco Trust images based on WebSphere.

## Features

- Use IBM SDK Java Technology Edition Version (IBM JDK)
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
  -p 9043:9043 \
  -p 9080:9080 \
  -p 9443:9443 \
  jenkins-deploy.fircosoft.net/trust/verify:<tag>
```

> Note that mapping ports will not work with WebSphere docker. This is a well know issue
  and a discussion is opened on https://github.com/WASdev/ci.docker.websphere-traditional/issues/180

The application is available on:

- https://localhost:9443/trust
- http://localhost:9080/trust

Open the WebSphere Admin Console by using https://localhost:9043/ibm/console.
The admin username is `wsadmin` and the password is `hello001`.

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

## Contribute

Submit a Pull Request with your changes following the official
[Docker Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
