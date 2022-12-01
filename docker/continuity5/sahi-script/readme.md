### Author 
Maamoun Soltani
#### About
The sahi image is an ubuntu based image, in which necessary binaries for sahi test running are included and sahi scripts are downloaded from bitbucket and run on the same container.
To this image a continuity v5 url is nedded as input and the html report is provided as output. 
#### Prerequisite
docker installed, internet connection.
#### How to
Run 
docker build --tag sahidocker .
docker run --env CTY_URL='http://10.55.62.172:33160/continuity/' --volume `pwd`/logs:/sahi_pro_911/userdata/logs/playback sahidocker
to start a sahi caontainer with reconfigured url in the env variable from the Dockerfile.
