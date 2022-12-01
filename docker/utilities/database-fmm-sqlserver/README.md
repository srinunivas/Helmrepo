# Trust Database Images

Docker images for Trust database Oracle & SQL Server for versions `4.x.x.x` and `5.x.x.x`.

## SQL Server Usage

```sh
# start an SQL Server database instance
docker run -i -p 1433:1433 jenkins-deploy.fircosoft.net/trust/database:<tag>

# sqlcmd usage
docker run -i --rm \
  jenkins-deploy.fircosoft.net/trust/database:<tag> \
  sqlcmd -S localhost -U $DB_USERNAME -P $DB_PASSWORD -d $DB_NAME -i /path/to/my/script.sql
```

**Found complete SQL Server documentation here: [http://dev-bitbucket.fircosoft.net/projects/FIR/repos/shadoker/browse/docker/trust/database/sqlserver](http://dev-bitbucket.fircosoft.net/projects/FIR/repos/shadoker/browse/docker/trust/database/sqlserver)**

## Oracle Usage

```sh
# start Oracle database instance
docker run -i -p 1521:1521 jenkins-deploy.fircosoft.net/trust/database:<tag>

# sqlplus usage
docker run -i -p 1521:1521 \
  jenkins-deploy.fircosoft.net/trust/database:<tag> \
  sqlplus sys/oracle as sysdba
```

**Found complete Oracle documentation here: [http://dev-bitbucket.fircosoft.net/projects/FIR/repos/shadoker/browse/docker/trust/database/oracle](http://dev-bitbucket.fircosoft.net/projects/FIR/repos/shadoker/browse/docker/trust/database/oracle)**
