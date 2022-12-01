# Firco Trust Docker Image for Tomcat

A Firco Trust images based on Tomcat.

## Features

- Use OpenJDK
- Have a self-signed SSL certificate (port `8443`)
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
  -p 8080:8080 \
  -p 8443:8443 \
  jenkins-deploy.fircosoft.net/trust/verify:<tag>
```

The application is available on:

- https://localhost:8443/trust
- http://localhost:8080/trust

## Environment Variables

| Variable          | Default       | Description                                                         |
|-------------------|---------------|---------------------------------------------------------------------|
| `AUTH_METHOD`     | `HEAVY_LOGIN` | Authentication method. Supported values: `HEAVY_LOGIN`, `LDAP`      |
| `CONTEXT_NAME`    | `trust`       | Application context name                                            |
| `TRUST_DB_DRIVER` |               | Database driver. Allow values: `oracle12`, `oracle19`, `sqlserver`  |
| `TRUST_DB_HOST`   |               | Database host                                                       |
| `TRUST_DB_PORT`   |               | Database port                                                       |
| `TRUST_DB_NAME`   |               | Database name                                                       |
| `TRUST_DB_USER`   |               | Database username                                                   |
| `TRUST_DB_PWD`    |               | Database password                                                   |

> **Note** that if you're trying to use Trust Verify with Oracle 19c which
  exposes an instance through a service name, must use `TRUST_DB_DRIVER=oracle19`

## Enable LDAP Basic Authentication

To enable LDAP Basic Authentication, make sure to set environment variable
`AUTH_METHOD=LDAP` and folowing variables:

| Variable                    | Description
|-----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------
| `LDAP_SERVER`               | URL of the LDAP server
| `LDAP_BASE_DN`              | The node in the LDAP tree below which the roles are defined
| `LDAP_USER`                 | The user name used to authenticate to a read-only LDAP connection. If left blank, an anonymous connection is attempted
| `LDAP_PASSWORD`             | The password used to establish a read-only LDAP connection. The password can be entered here in plain text or it can be encrypted
| `LDAP_USER_BASE`            | The base element for user searches performed using the userSearch expression. If not specified, the top level element in the directory context will be used
| `LDAP_USER_SEARCH`          | The LDAP filter expression to use when searching for a user's directory entry, with `{0}` marking where the actual user name should be inserted
| `LDAP_ROLE_ATTRIBUTE_NAME`  | Name of LDAP attribute used to determine role
| `LDAP_ROLE_SEARCH_PATTERN`  | Search pattern used to identify roles

**Note** LDAP settings is only available for Trust Verify V5 images.

You can found a Docker Compose usage here [samples folder](samples).

## Remote Debugging

To enable remote debugging, just set environment variable `REMOTE_DEBUGGING` to
`true` and then map the JPDA port `5005`.

```sh
docker run -i \
  -e REMOTE_DEBUGGING=true \
  -e CONTEXT_NAME=trust \
  -e TRUST_DB_HOST=<db-ip> \
  -e TRUST_DB_PORT=<db-port> \
  -e TRUST_DB_NAME=<db-name> \
  -e TRUST_DB_USER=<db-user> \
  -e TRUST_DB_PWD=<db-pwd> \
  -e TRUST_DB_DRIVER=<db-driver> \
  -p 8080:8080 \
  -p 8443:8443 \
  jenkins-deploy.fircosoft.net/trust/verify:<tag>
```

## Contribute

Submit a Pull Request with your changes following the official
[Docker Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
