# Easysoft Image

A CentOS based image with Oracle Linux and Easysoft Oracle ODBC Driver installed.
License is not included in the image and will be dynamically requested against database http://inventaire.fircosoft.net:5984/licenses

## Portus Link

  - Third Parties Namespace: https://portus.jenkins-deploy.fircosoft.net/namespaces/40
  - Image Repository: https://portus.jenkins-deploy.fircosoft.net/repositories/382

## Available tags

| Tag                         | Easysoft  | OS        | ODBC client               |
|-----------------------------|-----------|-----------|---------------------------|
| `3.8.0-centos7-oracle19.6`  | 3.8.0     | CentOS 7  | Oracle Client 19.6        |
| `3.8.0-centos7-oracle12.1`  | 3.8.0     | CentOS 7  | Oracle Client 12.1.0.2.0  |
| `3.5.1-centos7-oracle19.6`  | 3.5.1     | CentOS 7  | Oracle Client 19.6        |
| `3.5.1-centos7-oracle12.1`  | 3.5.1     | CentOS 7  | Oracle Client 12.1.0.2.0  |

## Usage

```sh
docker run -i \
  -e ODBC_DATASOURCE=TRUSTV5 \
  -e TNSNAME_ADDRESS_NAME=ORA12 \
  -e TNSNAME_SERVICE_NAME=PDBORCL \
  -e TNSNAME_HOSTNAME=10.55.63.3 \
  -e TNSNAME_PORT=1521 \
  -e DB_NAME=PDBORCL \
  -e DB_USERNAME=TRUSTV5 \
  -e DB_PASSWORD=Hello00 \
  jenkins-deploy.fircosoft.net/third-parties/easysoft:<tag> bash
```

## Environment Variables

| Variable                | Default value | Description                       |
|-------------------------|---------------|-----------------------------------|
| `ODBC_DATASOURCE`       |               | The ODBC datasource name to use   |
| `TNSNAME_ADDRESS_NAME`  |               | Oracle server address name        |
| `TNSNAME_SERVICE_NAME`  |               | Oracle service name               |
| `TNSNAME_HOSTNAME`      |               | Oracle server host                |
| `TNSNAME_PORT`          | `1521`        | Oracle port                       |
| `DB_NAME`               |               | Database name                     |
| `DB_USERNAME`           |               | Database username                 |
| `DB_PASSWORD`           |               | Username password                 |

## Versioning

Given a version number `EASYSOFT_VERSION-OS_VERSION-ODBC_CLIENT_VERSION`,
increment the:

| Increment             | Description                         | Example               |
|-----------------------|-------------------------------------|-----------------------|
| `EASYSOFT_VERSION`    | The Trust Batch version installed   | `2.3.1`, `2.3.7`      |
| `OS_VERSION`          | The image OS version                | `centos7`, `centos8`  |
| `ODBC_CLIENT_VERSION` | The Oracle Client version installed | `oracle-client12.1`   |

## Contribute

Submit a Pull Request with your changes following the official
[Docker Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
