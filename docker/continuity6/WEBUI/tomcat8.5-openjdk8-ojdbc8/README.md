# Run image

```sh
docker run  \
--rm \
--name WEBUI \
-p 4937:8080 \
-e DB_USER=D_CTY_6300_51_OMB -e DB_PASSWORD=hello00 \
-e DB_URL=jdbc:oracle:thin:@quarouble.fircosoft.net:1522/PDBORADEV \
jenkins-deploy.fircosoft.net/continuity6/cty-webui:master-tomcat8.5-openjdk8-ojdbc8-dev
```    