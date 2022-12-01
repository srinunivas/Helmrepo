# Fircosoft HPR docker image

This is the official image of Continuity High Performance requester 

## How to run the image
To run an image use the docker run command as follows:

Ex:

    $ docker run  --rm --name HPR \
                        -p 4444:4444 \
                        -p 1022:22 \
                        -v "`pwd`/data/hpr/conf":"/usr/local/conf" \
                        -v "`pwd`/data/hpr/ssl":"/usr/local/ssl" \
                        -v "`pwd`/data/uf":"/usr/local/fw/dropbox" \
                        jenkins-deploy.fircosoft.net/continuity6/high-performance-requester-oel7:6.3.0.0


There are 3 bounded volumes must be created before :

- `data/hpr/conf` : contains HPR configuration file, license file & nginx template file
- `data/hpr/ssl`  : contains jks keys serverKeystore.jks for TLS  & serverTruststore for mTLS 
- `data/uf` : contains the dropbox of filter resources and splitting configurations

#### Example of `data` volume folder


     data    
        ├── hpr
        │   ├── conf
        │   │   ├── fbe.cf
        │   │   ├── HighPerformanceRequester.properties
        │   │   └── nginx.conf.ftl
        │   └── ssl
        │       ├── serverKeystore.jks
        │       └── serverTruststore.jks
        └── uf
            ├── uf_res
            │   ├── config.json
            │   ├── filter.srz
            │   ├── fkof.res
            │   ├── fml.rul
            │   ├── fmlxx.rul
            │   ├── fof.cf
            │   ├── FOFDB.kz
            │   ├── format.ffm
            │   ├── splitting-config.json
            │   └── test
            ├── uf_res2
            │   ├── config.json
            │   ├── filter.srz
            │   ├── fkof.res
            │   ├── fml.rul
            │   ├── fmlxx.rul
            │   ├── fof.cf
            │   ├── FOFDB.kz
            │   ├── format.ffm
            │   ├── splitting-config.json
            │   └── test
            └── uf_res3
                ├── config.json
                ├── fkof.res
                ├── fml.rul
                ├── fmlxx.rul
                ├── fof.cf
                ├── FOFDB.kz
                └── splitting-config.json


