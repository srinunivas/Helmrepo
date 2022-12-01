# Docker for Oracle database

Image published on Potus has been created using the official Oracle
documentation https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance

## Portus Link

  - Third Parties Namespace: https://portus.jenkins-deploy.fircosoft.net/namespaces/40
  - Image Repository: https://portus.jenkins-deploy.fircosoft.net/repositories/387

## Usage

Start database instance:

```sh
docker run -i -p 1521:1521 jenkins-deploy.fircosoft.net/third-parties/oracle:19.3.0-ee
```

If you want to execute `sqlplus`:

```sh
# for an image with Oracle 12c
docker run -i --rm \
  jenkins-deploy.fircosoft.net/third-parties/oracle:<tag> \
    sqlplus sys/oracle as sysdba

# for an image with Oracle 19c
docker run -i --rm \
  jenkins-deploy.fircosoft.net/third-parties/oracle:<tag> \
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
