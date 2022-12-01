# Easysoft Image

Found documentation here: 
[http://dev-bitbucket.fircosoft.net/projects/FIR/repos/shadoker/browse/docker/third-parties/easysoft/README.md](http://dev-bitbucket.fircosoft.net/projects/FIR/repos/shadoker/browse/docker/third-parties/easysoft/README.md)

## Usage

```sh
docker run -i \
  -e ODBC_DATASOURCE=TRUSTV5 \
  -e TNSNAME_ADDRESS_NAME=ORA12 \
  -e TNSNAME_SERVICE_NAME=PDBORCL \
  -e TNSNAME_HOSTNAME=10.55.63.3 \
  -e TNSNAME_PORT=1521 \
  -e DB_NAME=PDBORCL \
  -e DB_USERNAME=TRUSTV5 \
  -e DB_PASSWORD=Hello00 \
  jenkins-deploy.fircosoft.net/third-parties/easysoft:<tag> bash
```

## Environment Variables

  - `ODBC_DATASOURCE`       : The ODBC datasource name to use   
  - `TNSNAME_ADDRESS_NAME`  : Oracle server address name        
  - `TNSNAME_SERVICE_NAME`  : Oracle service name               
  - `TNSNAME_HOSTNAME`      : Oracle server host                
  - `TNSNAME_PORT` (default `1521`):  Oracle port                       
  - `DB_NAME`               : Database name                     
  - `DB_USERNAME`           : Database username                 
  - `DB_PASSWORD`           : Username password                 

> For more info please follow [http://dev-bitbucket.fircosoft.net/projects/FIR/repos/shadoker/browse/docker/third-parties/easysoft/README.md](http://dev-bitbucket.fircosoft.net/projects/FIR/repos/shadoker/browse/docker/third-parties/easysoft/README.md)
