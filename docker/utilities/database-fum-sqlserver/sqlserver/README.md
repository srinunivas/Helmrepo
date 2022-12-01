# FUM Database SQL Server Image

Docker image for FUM database SQL Server.

## Portus Link

- Utilities Namespace: https://portus.jenkins-deploy.fircosoft.net/namespaces/77
- FUM Database Image Repository: https://portus.jenkins-deploy.fircosoft.net/repositories/263

## Usage

```sh
# start database instance
docker run -i -p 1433:1433 jenkins-deploy.fircosoft.net/trust/utilities/fum-database:<tag>

# sqlcmd usage
docker run -i --rm \
  jenkins-deploy.fircosoft.net/utilities/fum-database:<tag> \
  sqlcmd -S localhost -U $DB_USERNAME -P $DB_PASSWORD -d $DB_NAME -i /path/to/my/script.sql
```