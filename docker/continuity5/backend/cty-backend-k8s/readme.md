# Images for Fircosoft Backend
These images contain a coreengine and all backend modules with the given versions.

## How to auto-generate the imageData files and the artifacts files
To generate the imageData files and the references/artifacts files automaticcally, you can use the tool manifesto

    $ CORENGINE_VERSIONS=5.6.5.9,5.6.12.0,5.6.13.0,5.6.13.1
    $ FILTER_VERSIONS=5.8.12.0
    $ PRODUCT_VERSION=5.3.25.1
    $ MULTIPLEXER_VERSION=5.3.25.0
    $ REQUESTER_VERSION=5.3.25.0
    $ DBCLIENT_VERSION=5.3.25.0
    $ DBTOOLS_VERSION=5.3.23.0
    $ PAIRING_VERSION=5.3.23.0
    $ STRIPPING_VERSION=5.3.25.0
    $ JSONUTILITIES_VERSION=5.3.16.11
    $ MAPPINGHTTPSTATUS_VERSION=5.3.16.12
    $ MAPPINGCASEMANAGERAPI_VERSION=5.3.16.3
    $ FIRCOCONTRACTMAPPER_VERSION=5.3.25.0
    $ MAPPINGXMLUNIVERSAL_VERSION=5.3.25.1
    $ ADVANCEDREPORTING_VERSION=5.3.24.0
    $ DRCHECKSUMMIGRATOR_VERSION=5.3.23.0
    $ PREDICTIONINTEGRATOR_VERSION=5.3.21.0
    $ ARCHIVING_VERSION=5.3.25.0
    $ docker run --rm \
        -e CORENGINE_VERSIONS=${CORENGINE_VERSIONS} \
        -e PRODUCT_VERSION=${PRODUCT_VERSION} \
        -e MULTIPLEXER_VERSION=${MULTIPLEXER_VERSION} \
        -e REQUESTER_VERSION=${REQUESTER_VERSION} \
        -e DBCLIENT_VERSION=${DBCLIENT_VERSION} \
        -e DBTOOLS_VERSION=${DBTOOLS_VERSION} \
        -e PAIRING_VERSION=${PAIRING_VERSION} \
        -e STRIPPING_VERSION=${STRIPPING_VERSION} \
        -e JSONUTILITIES_VERSION=${JSONUTILITIES_VERSION} \
        -e MAPPINGHTTPSTATUS_VERSION=${MAPPINGHTTPSTATUS_VERSION} \
        -e MAPPINGCASEMANAGERAPI_VERSION=${MAPPINGCASEMANAGERAPI_VERSION} \
        -e FIRCOCONTRACTMAPPER_VERSION=${FIRCOCONTRACTMAPPER_VERSION} \
        -e MAPPINGXMLUNIVERSAL_VERSION=${MAPPINGXMLUNIVERSAL_VERSION} \
        -e ADVANCEDREPORTING_VERSION=${ADVANCEDREPORTING_VERSION} \
        -e DRCHECKSUMMIGRATOR_VERSION=${DRCHECKSUMMIGRATOR_VERSION} \
        -e PREDICTIONINTEGRATOR_VERSION=${PREDICTIONINTEGRATOR_VERSION} \
        -e ARCHIVING_VERSION=${ARCHIVING_VERSION} \
        -v $(pwd):/shadoker \
        -w /shadoker \
        jenkins-deploy.fircosoft.net/shadoker/manifesto \
        --no-color \
        --generate-metadata \
        docker/continuity5/backend/cty-backend-k8s/backend-k8s.mjs

## How to build an image for a specific version of the DBClient
To assist in building the images, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh ./shadoker-cli.sh docker build -d <my_image_name:my_tag>

See confluence page for more information : http://confluence.fircosoft.net/pages/viewpage.action?spaceKey=DTP&title=Shadoker+usage+for+development+teams

Or 

    $ ./shadoker-cli.sh -help

Ex:

    $ ./shadoker-cli.sh docker build -d jenkins-deploy.fircosoft.net/continuity5/backend-k8s:5.3.25.1-centos7-coreengine5.6.13.1

## How to generate the refernces/images files after having build an image
To assist in generating the refernces/images file, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh docker update jenkins-deploy.fircosoft.net/continuity5/backend-k8s:5.3.25.1-centos7-coreengine5.6.13.1

Note : the image needs to be pushed in the Portus for this to work correctly.

## How to run the image
To run an image use the docker run command as follows:
Ex:
To run a bash in the container
    $ docker run  \
        --name backend-k8s-5.3.25.1-centos7-coreengine5.6.13.1 \
        -it --rm \
        --entrypoint /bin/bash \
        jenkins-deploy.fircosoft.net/continuity5/backend-k8s:5.3.25.1-centos7-coreengine5.6.13.1

To display the help message of the CoreEngine in the container
    $ docker run  \
        --name backend-k8s-5.3.25.1-centos7-coreengine5.6.13.1 \
        -it --rm \
        jenkins-deploy.fircosoft.net/continuity5/backend-k8s:5.3.25.1-centos7-coreengine5.6.13.1 \
        -help
