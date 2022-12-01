# Run image

Set the administrator password for use with http://localhost:9043/ibm/console. The *"User ID"* will be **wsadmin**:
```
$ echo "(password)" > $(pwd)/PASSWORD
```

Run the server:
```
$ docker run --name websphere \
-p 9043:9043 -p 9443:9443 -p 9080:9080 \
-e "DB_USER=D_SA" -e "DB_PASSWORD=Charleroi0" -e "DB_URL=jdbc:sqlserver://charleroi.fircosoft.net:1433;databaseName=NR1_6300_SQL" \
-v $(pwd)/PASSWORD:/tmp/PASSWORD \
jenkins-deploy.fircosoft.net/continuity6/cty-webui:master-websphere9.0.5.3-openjdk8-mssqljdbc8.2.0-dev
```
