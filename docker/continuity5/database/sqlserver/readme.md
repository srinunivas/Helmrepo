# Images for Fircosoft Continuity DB
These images contain an oracle server 19.0.3 enterprise edition and a db user for a specific version of the Continuity DB.
This oracle edition is limited to development usage.

## How to auto-generate the imageData files and the artifacts files
To generate the imageData files and the references/artifacts files automaticcally, you can use the tool manifesto

```sh
docker run -it --rm -e CONTINUITY_DB_VERSION='5.3.19.0' -v $(pwd):/shadoker -w /shadoker jenkins-deploy.fircosoft.net/shadoker/manifesto docker/continuity5/database/sqlserver/database.mjs
```

## How to build an image for a specific version of the Continuity DB
To assist in building the images, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

```sh
./shadoker-cli.sh ./shadoker-cli.sh docker build -d <my_image_name:my_tag>
```

See confluence page for more information : http://confluence.fircosoft.net/pages/viewpage.action?spaceKey=DTP&title=Shadoker+usage+for+development+teams

Or 

```sh
./shadoker-cli.sh -help
```

Ex:

```sh
./shadoker-cli.sh docker build -d jenkins-deploy.fircosoft.net/continuity5/database:5.3.19.0-sqlserver2019
```

## How to run the image
Start database instance:

```sh
docker run -i -p 1433:1433 --name continuity5-database-5.3.19.0-sqlserver2019 jenkins-deploy.fircosoft.net/continuity5/database:5.3.19.0-sqlserver2019
```

If you want to execute `sqlcmd`:

```sh
docker run -i --rm \
  jenkins-deploy.fircosoft.net/continuity5/database:5.3.19.0-sqlserver2019 \
  sqlcmd -S localhost -U \$DB_USERNAME -P \$DB_PASSWORD -d \$DB_NAME -i /path/to/my/script.sql
```

## Default Settings

| Setting       | Value          | Description              |
|---------------|----------------|--------------------------|
| User          | `continuity`   | Continuity user name     |
| Password      | `hello00`      | Continuity user password |
| Database Name | `continuitydb` | Continuity database name |

**Note** Use the user `sa` and the password `Hello00123` to login as the super administrator.
