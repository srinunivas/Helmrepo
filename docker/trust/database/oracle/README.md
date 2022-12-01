# Trust Database Oracle Image

Docker image for Trust database Oracle from version `4.x.x.x` to `5.x.x.x`
created from the base image [jenkins-deploy.fircosoft.net/third-parties/oracle:19.3.0-ee](https://portus.jenkins-deploy.fircosoft.net/repositories/387)

**Note that Trust Verify Web licenses are already installed on each image**.

## Portus Link

  - Trust Namespace: https://portus.jenkins-deploy.fircosoft.net/namespaces/25
  - Image Repository: https://portus.jenkins-deploy.fircosoft.net/repositories/73

## Usage

Start database instance:

```sh
docker run -i -p 1521:1521 jenkins-deploy.fircosoft.net/trust/database:<tag>
```

If you want to execute `sqlplus`:

```sh
# for an image with Oracle 12c
docker run -i --rm \
  jenkins-deploy.fircosoft.net/trust/database:<tag> \
    sqlplus sys/oracle as sysdba

# for an image with Oracle 19c
docker run -i --rm \
  jenkins-deploy.fircosoft.net/trust/database:<tag> \
    sqlplus sys/\$ORACLE_PWD@ORCLPDB1 as sysdba
```

## Database Instance Settings

**Oracle 19c**

| Setting                       | Value                 |
|-------------------------------|-----------------------|
| Oracle SID                    | `ORCLCDB`             |
| Oracle PDB                    | `ORCLPDB1`            |
| SYS password                  | `Fircosoft00`         |
| ORACLE_CHARACTERSET           | `AL32UTF8`            |
| Oracle Listener port          | `1521`                |
| OEM Express port              | `5500`                |
| Data volume for the database  | `/opt/oracle/oradata` |

**Oracle 12c**

| Setting                       | Value                 |
|-------------------------------|-----------------------|
| Oracle SID                    | `XE`                  |
| ORACLE_CHARACTERSET           | `AL32UTF8`            |
| SYS password on Oracle 12c    | `oracle`              |
| Oracle Listener port          | `1521`                |
| Data volume for the database  | `/opt/oracle/oradata` |

## Versioning

Given a version number `TRUST_VERSION-RDBMS`, increment the:

| Increment             | Description                             | Example                           |
|-----------------------|-----------------------------------------|-----------------------------------|
| `TRUST_VERSION`       | The Trust Database version installed    | `4.7.0.0`                         |
| `RDBMS`               | The RDBMS installed                     | `oracle12cxe` for `Oracle 12c XE` |

## Contribute

Submit a Pull Request with your changes following the official
[Docker Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
