# Trust FSK Docker Image

A Trust FSK image based on
[Unix ODBC & Oracle Client Image](https://portus.jenkins-deploy.fircosoft.net/repositories/265).

## Portus Link

  - Trust Namespace: https://portus.jenkins-deploy.fircosoft.net/namespaces/25
  - Trust FSK Repository: https://portus.jenkins-deploy.fircosoft.net/repositories/136

## Usage

**FFFSRVC, FFFSRVM, OFICPUT, OFIPWD, OFIQPUT, OFISTOP**

```sh
docker run -i \
  -v $(pwd):/data \
  -w /data \
  jenkins-deploy.fircosoft.net/trust/fsk:<tag> FFFSRVM -OPTIONS=config.cfg
```

**FFFDIOC, FFFDIOM, PMWDOG**

```sh
docker run -i \
  -e ODBC_DATASOURCE=trust \
  -e TNSNAME_SERVICE_NAME=XE \
  -e TNSNAME_ADDRESS_NAME=XE \
  -e TNSNAME_HOSTNAME=10.55.63.3 \
  -e TNSNAME_PORT=1521 \
  -e DB_NAME=trust \
  -e DB_USERNAME=trust \
  -e DB_PASSWORD=hello00 \
  -v $(pwd):/data \
  -w /data \
  jenkins-deploy.fircosoft.net/trust/fsk:<tag> FFFDIOM -OPTIONS=config.cfg
```

## Basic Integration Sample

The folder [`sample/`](sample) includes a Docker Compose example with both
FSK OFICPUT Docker image and IBM MQ image.

## Environment Variables

| Variable                | Default value | Description                       |
|-------------------------|---------------|-----------------------------------|
| `PRESET_ENV`            | `false`       | Automatically preset ODBC env     |
| `ODBC_DATASOURCE`       |               | The ODBC datasource name to use   |
| `TNSNAME_ADDRESS_NAME`  |               | Oracle server address name        |
| `TNSNAME_SERVICE_NAME`  |               | Oracle service name               |
| `TNSNAME_HOSTNAME`      |               | Oracle server host                |
| `TNSNAME_PORT`          | `1521`        | Oracle port                       |
| `DB_NAME`               |               | Database name                     |
| `DB_USERNAME`           |               | Database username                 |
| `DB_PASSWORD`           |               | Username password                 |

See [dockerfiles/unixodbc-oracle-client](http://dev-bitbucket.fircosoft.net/projects/TRUSTV4/repos/dockerfiles/browse/unixodbc-oracle-client)
for more information about environment variables.

**Note about `PRESET_ENV`**

By default, the *entrypoint* script runs `FFFDIOC`, `FFFDIOM` and `PMWDOG`
on a ODBC environment.

- This means it automatically create `.odbc.ini` file and all necessary
  configurations to allow programs to use the ODBC layer
- This also means that if you start the container with a custom script
  shell, the ODBC environment will not be setted and your script will
  be executed in a *normal shell*.

To enable the automatically configure the ODBC environment at the
container startup, define the environment variable `PRESET_ENV` to `true`.

## Versioning

Given a version number `TRUST_VERSION-OS_VERSION-ODBC_MANAGER-ODBC_CLIENT`,
increment the:

| Increment       | Description                                     | Example                                                                   |
|-----------------|-------------------------------------------------|---------------------------------------------------------------------------|
| `TRUST_VERSION` | The Trust FSK version installed in the image    | `5.1.1.0`, `5.0.0.0`                                                      |
| `OS_VERSION`    | The image OS version                            | `centos7` for CentOS 7, `centos8` for CentOS 8                            |
| `ODBC_MANAGER`  | The ODBC manager installed in the image         | `unixodbc2.3.1`, `easysoft3.5`                                            |
| `ODBC_CLIENT`   | The ODBC client installed in the image          | `oracle12.1` for Oracle Client 12.1, `SQLSERVER2017` for SQL Server 2017  |
| `MQ_CLIENT`     | The MQ client installed in the image            | `webspheremq7.5.0.2` for IBM Webphere MQ 7.5.0.2                          |

## Contribute

Submit a Pull Request with your changes following the official
[Docker Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
