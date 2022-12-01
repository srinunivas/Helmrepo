# Images for Fircosoft Fmm Java Batch
These images contain a ListManager-JavaBatch.jar and a Java jre allowing to execute that .jar.

## How to build an image for a specific version of the DBClient
To assist in building the images, you can use the [shadoker-cli.bat](shadoker-cli.bat) script. See below for instructions and usage.

        shadoker-cli.bat build -d <my_image_name:my_tag>

See confluence page for more information : http://confluence.fircosoft.net/pages/viewpage.action?spaceKey=DTP&title=Shadoker+usage+for+development+teams

Or 

        shadoker-cli.bat -help

Ex:
        shadoker-cli.bat docker build -d jenkins-deploy.fircosoft.net/utilities/javabatch-fmm:4.12.5.0

## How to generate the refernces/images files after having build an image
To assist in generating the refernces/images file, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

        shadoker-cli.bat docker update jenkins-deploy.fircosoft.net/utilities/javabatch-fmm:4.12.5.0

Note : the image needs to be pushed in the Portus for this to work correctly.
