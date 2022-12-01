# Case Manager API docker documentation

Here is some useful information.

- The package is unzipped under **`/opt/cty-backend`**.
- The standard start script (`/opt/cty-backend/ContinuityCaseManagerAPI/Start_CaseManagerAPI.sh`)
  is used to launch the Case Manager API program.
- By default the `Java 8` is used. If Java 11 is desired, add
  "`-e JAVA_VERSION=11`" to the docker run parameters. Java 8 and
  Java 11 are installed.
- You can replace *any file or directory* via "`-v` (or `--volume`)". (true for any docker)
- If you give `[COMMAND] [ARG...]` after the IMAGE argument of `docker run` command,
  i.e. `docker run ... jenkins-deploy.fircosoft.net/continuity6/cty-cmapi:master java -version`,
  in such a case `java -version` will be executed instead of the Case Manager API.
  In other words, `[COMMAND] [ARG...]` overrides the Case Manager API start script execution.

Docker run command example:
```sh
$ docker run \
-v /tmp/my-cmapi-config.properties:/opt/cty-backend/conf/CaseManagerAPI.properties \
-v /tmp/backend-log:/opt/cty-backend/log \
-it --hostname cmapi-host --name cmapi --rm \
-e JAVA_VERSION=11 \
jenkins-deploy.fircosoft.net/continuity6/cty-cmapi:master
```

- You can also make use of **Environment Variables** to let values undefined in the configuration file
  until the runtime. For example
```
database.dbcty.type=${DBTYPE}
database.dbcty.url=${DBURL}
database.dbcty.username=${DBUSERNAME}
database.dbcty.password=${DBPASSWORD}
```
  this configuration file allows defining the Database related information at `docker run` command invocation:
```sh
$ docker run \
-v /tmp/placeholder-config.properties:/opt/cty-backend/conf/CaseManagerAPI.properties \
-e DBTYPE=SqlServer \
-e DBURL=jdbc:sqlserver://vancouver.fircosoft.net:1433;databaseName=D_CTY_6400_999_DEV \
-e DBUSERNAME=sa \
-e DBPASSWORD=Pantera01 \
jenkins-deploy.fircosoft.net/continuity6/cty-cmapi:master

# or, prepare any number of ENV files like this and select one at invocation
$ cat db_env
DBTYPE=Oracle
DBURL=jdbc:oracle:thin:@bonaventure.fircosoft.net:1521/oraqadev
DBUSERNAME=D_CTY_6400_999_DEV
DBPASSWORD=hello00

$ docker run \
-v /tmp/placeholder-config.properties:/opt/cty-backend/conf/CaseManagerAPI.properties \
--env-file db_env \
jenkins-deploy.fircosoft.net/continuity6/cty-cmapi:master
```
This mechanism can be applied to any properties in the configuration file.

## N.B.
- As of the initial version, the license file for 6.4.0.0 is included and placed `/opt/cty-backend/conf/fbe.cf`.