# Unix ODBC Oracle Client Configuration

## 1. Create a new datasource

First, define a new datasource in `odbc.ini` file:

```ini
[<datasource>]
Driver=ORACLE
Database=xe
ServerName=xe
User=<username>
Password=<password>
METADATA_ID=0
ENABLE_USER_CATALOG=1
ENABLE_SYNONYMS=1
```

## 2. Configure Oracle Client

Then create the `tnsnames.ora` file:

```sh
<addressname> =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = <hostname>)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = <service-name>)
    )
  )
```

| Variable          | Description             | Exemple       |
|-------------------|-------------------------|---------------|
| `<addressname>`   | Server name             | `ORA12`       |
| `<hostname>`      | Oracle server host      | `12.34.56.78` |
| `<service-name>`  | Oracle service name     | `xe`          |

**Exemple tnsnames.ora**

```sh
xe =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.19.14.41)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = xe)
    )
  )
```

**Links**
- [Tnsnames.ora](http://www.orafaq.com/wiki/Tnsnames.ora)
- [Local Naming Parameters in the tnsnames.ora File](https://docs.oracle.com/database/121/NETRF/tnsnames.htm#NETRF007)

## 3. Start a container

```sh
docker run -it --rm \
  --volume tnsnames.ora:/usr/lib/oracle/12.1/client/network/admin/tnsnames.ora \
  --volume odbc.ini:/root/odbc.ini \
  jenkins-deploy.fircosoft.net/trust/unixodbc-oracle-client
```
