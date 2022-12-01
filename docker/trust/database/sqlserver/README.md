# Trust Database SQL Server Image

Docker image for Trust database SQL Server from version `4.x.x.x` to `5.x.x.x`.

**Note that Trust Verify Web licenses are already installed on each image**.

## Portus Link

- Trust Namespace: https://portus.jenkins-deploy.fircosoft.net/namespaces/25
- Image Repository: https://portus.jenkins-deploy.fircosoft.net/repositories/73

## Usage

Start database instance:

```sh
docker run -i -p 1433:1433 jenkins-deploy.fircosoft.net/trust/database:<tag>
```

If you want to execute `sqlcmd`:

```sh
docker run -i --rm \
  jenkins-deploy.fircosoft.net/trust/database:<tag> \
  sqlcmd -S localhost -U \$DB_USERNAME -P \$DB_PASSWORD -d \$DB_NAME -i /path/to/my/script.sql
```

## Default Settings

| Setting       | Value     | Description         |
|---------------|-----------|---------------------|
| User          | `trust`   | Trust user name     |
| Password      | `hello00` | Trust user password |
| Database Name | `trustdb` | Trust database name |

**Note** Use the user `sa` and the password `Hello00123` to login as the super administrator.

## Versioning

Given a version number `TRUST_VERSION-RDBMS`, increment the:

| Increment             | Description                             | Example                               |
|-----------------------|-----------------------------------------|---------------------------------------|
| `TRUST_VERSION`       | The Trust Database version installed    | `4.7.0.0`                             |
| `RDBMS`               | The RDBMS installed                     | `sqlserver2019` for `SQL Server 2019` |

## Contribute

Submit a Pull Request with your changes following the official
[Docker Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
