# Fircosoft Continuity Migration Tools docker image

This is the official image of Fircosoft Continuity Migration Tools

## How to run this image

To run this image use the docker run command as follows:

    $ docker run --rm --name MIG                                      \
                      -v "`pwd`/conf:/usr/local/migration-tools/conf" \
                      -v "`pwd`/log:/usr/local/migration-tools/log"   \
                      -v "`pwd`/tmp:/usr/local/migration-tools/tmp"   \
                      jenkins-deploy.fircosoft.net/continuity6/migration-tools:mig-release-1.0.0.0-alpine-openjdk11

There are 3 bounded volumes that must be created beforehand:

- `conf`: contains appropriate licence `fbe.cf`, broker config file `broker.xml` and migration tools config file `MigrationTools.properties`
- `log` : an empty folder that will contain migration tools log files
- `tmp` : an empty folder that will contain migration tools temporary files
