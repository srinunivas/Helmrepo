# Images for Fircosoft DBClient
These images contain a coreengine and a dbclient of a specific version.

## How to auto-generate the imageData files and the artifacts files
To generate the imageData files and the references/artifacts files automaticcally, you can use the tool manifesto

    $ docker run --rm -e JDBCPROXY_VERSION=5.6.13.1_k8s -v $(pwd):/shadoker -w /shadoker jenkins-deploy.fircosoft.net/shadoker/manifesto --no-color --generate-metadata docker/continuity5/backend/jdbcproxy/jdbcproxy.mjs

## How to build an image for a specific version of the DBClient
To assist in building the images, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh ./shadoker-cli.sh docker build -d <my_image_name:my_tag>

See confluence page for more information : http://confluence.fircosoft.net/pages/viewpage.action?spaceKey=DTP&title=Shadoker+usage+for+development+teams

Or 

    $ ./shadoker-cli.sh -help

Ex:

    $ ./shadoker-cli.sh docker build -d jenkins-deploy.fircosoft.net/continuity5/jdbcproxy:5.6.13.1-k8s-alpinejre-11.0.11_9-openjdk11-develop

## How to generate the refernces/images files after having build an image
To assist in generating the refernces/images file, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh docker update jenkins-deploy.fircosoft.net/continuity5/jdbcproxy:5.6.13.1-k8s-alpinejre-11.0.11_9-openjdk11-develop

Note : the image needs to be pushed in the Portus for this to work correctly.
