# Images for Fircosoft Web front-end
These image contain a tomcat server and a continuity deployed within

## How to auto-generate the imageData files and the artifacts files
To generate the imageData files and the references/artifacts files automaticcally, you can use the tool manifesto

    $ docker run -it --rm -e PRODUCT_VERSION='5.3.25.1' -e FRONTEND_VERSION='5.3.25.1' -v $(pwd):/shadoker -w /shadoker jenkins-deploy.fircosoft.net/shadoker/manifesto docker/continuity5/frontend/tomcat-autogenerated/tomcat.mjs

## How to build an image for a specific version of the DBClient
To assist in building the images, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh ./shadoker-cli.sh docker build -d <my_image_name:my_tag>

See confluence page for more information : http://confluence.fircosoft.net/pages/viewpage.action?spaceKey=DTP&title=Shadoker+usage+for+development+teams

Or 

    $ ./shadoker-cli.sh -help

Ex:

    $ ./shadoker-cli.sh docker build -d jenkins-deploy.fircosoft.net/continuity5/verify-web:5.3.25.1-tomcat9.0.37-openjdk11-continuity5.3.25.1

## How to generate the references/images files after having build an image
To assist in generating the refernces/images file, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh docker update jenkins-deploy.fircosoft.net/continuity5/verify-web:5.3.25.1-tomcat9.0.37-openjdk11-continuity5.3.25.1

Note : the image needs to be pushed in the Portus for this to work correctly.

## How to run the image
To run an image use the docker run command as follows:

Ex:

    $ docker run \
        --name tomcat-9.0-container \
        -p 9280:8080 \
        -p 9243:8443 \
        -e DB_VENDOR=oracle \
        -e DB_USER=D_CTY_53X_999_EME \
        -e DB_PASSWORD=hello00 \
        -e DB_URL="jdbc:oracle:thin:@quarouble.fircosoft.net:1522/PDBORADEV" \
        -e DB_DRIVER=oracle.jdbc.OracleDriver \
        -it -d \
        jenkins-deploy.fircosoft.net/continuity5/verify-web:5.3.25.1-tomcat9.0.37-openjdk11-continuity5.3.25.1

    $ docker run \
        --name tomcat-9.0-container \
        -p 9280:8080 \
        -p 9243:8443 \
        -e DB_VENDOR=microsoft \
        -e DB_USER=DEV_USER \
        -e DB_PASSWORD=Hello00 \
        -e DB_URL="jdbc:sqlserver://vancouver.fircosoft.net:1433;databaseName=CTY_53190_EME" \
        -e DB_DRIVER=com.microsoft.sqlserver.jdbc.SQLServerDriver \
        -it -d \
        jenkins-deploy.fircosoft.net/continuity5/verify-web:5.3.25.1-tomcat9.0.37-openjdk11-continuity5.3.25.1