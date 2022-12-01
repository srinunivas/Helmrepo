# Images for Fircosoft Continuity webui
These images contain an oracle weblogic 12.2.1.4 and webapp for continuity alert review and Decision workflow

## Run weblogic image

```
docker run --name continuity \
-p 7001:7001 -p 9002:9002    \
-e DB_VENDOR=<db_vendor>  \
-e DB_USER=<db_user>      \
-e "DB_URL=<db_url>"      \
-e DB_PASSWORD=<db_password> \
jenkins-deploy.fircosoft.net/continuity6/cty-webui:master-weblogic-jdk8-dev-latest
```

#### Environement variables:
| Variable          | Description                                                                |
|-------------------|----------------------------------------------------------------------------|
| `DB_VENDOR`       | Database vendor. Allow values: `oracle | sqlserver`, default value `oracle`|
| `DB_URL`          | Database url                                                               |
| `DB_USER`         | Database user                                                              |
| `DB_PASSWORD`     | Database password                                                          |


>:exclamation: In case of sqlserver configuration ,  for `DB_URL` ~~use ***jdbc:weblogic:sqlserver*** instead of ***jdbc:sqlserver***~~ keep ***jdbc:sqlserver***

Admin console :
  - link: https://localhost:9002/console
  - login: **weblogic**
  - password: **welcome1**

Application link : http://localhost:7001/continuity

>The application is reachable when the container is **healthy**

#### Examples:
Run the image with **oracle** database configuration:
```
docker run --name continuity \
-p 7001:7001 -p 9002:9002    \
-e DB_URL=jdbc:oracle:thin:@quarouble.fircosoft.net:1522/PDBORADEV \
 -e DB_USER=D_CTY_6300_61_OMB \
 -e DB_PASSWORD=hello00 \
jenkins-deploy.fircosoft.net/continuity6/cty-webui:master-weblogic-jdk8-dev-latest
```
Run the image with **mircosoft sql sever** database configuration:



~~docker run --name continuity \
-p 7001:7001 -p 9002:9002    \
-e DB_VENDOR=sqlserver    \
-e "DB_URL=jdbc:weblogic:sqlserver://charleroi.fircosoft.net;databaseName=NR1_6300_SQL" \
 -e DB_USER=D_SA \
 -e DB_PASSWORD=Charelroi1 \
jenkins-deploy.fircosoft.net/continuity6/cty-webui:master-weblogic-jdk8-dev-latest~~

```
docker run --name continuity \
-p 7001:7001 -p 9002:9002    \
-e DB_VENDOR=sqlserver    \
-e "DB_URL=jdbc:sqlserver://charleroi.fircosoft.net;databaseName=NR1_6300_SQL" \
 -e DB_USER=D_SA \
 -e DB_PASSWORD=Charelroi1 \
jenkins-deploy.fircosoft.net/continuity6/cty-webui:master-weblogic-jdk8-dev-latest
```