# Run image

```sh
docker run  \
--rm \
--name WEBUI \
-p 4937:8080 \
-e DB_USER=D_SA -e DB_PASSWORD=Charleroi2 \
-e "DB_URL=jdbc:sqlserver://charleroi.fircosoft.net:1433\;databaseName=NR1_6300_SQL" \
jenkins-deploy.fircosoft.net/continuity6/cty-webui:master-tomcat8.5-openjdk8-mssqljdbc8.2.0-dev
```    
