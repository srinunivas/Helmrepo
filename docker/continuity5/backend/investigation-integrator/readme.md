# Image for Investigation Integrator
This image contains a simulator of an investigation integrator allowing to get more informations about messages.
The image is based on centos.


## How to build the image
To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that provides an easy way for beginners to get started.

    $ ./buildDockerImage.sh --imageData image-data-file --uri investigation-integrator-uri
    
    Usage: buildDockerImage.sh [-t image-name] --imageData image-data-file --uri investigation-integrator-uri
    Builds an Investigation Integrator Image from a centos image.
    
    Parameters:
       -t: tags the docker image with image-name. Default value is the name of the containing directory.
       --imageData            : Image data file with all dependencies ; file path with extension
       --uri : investigation integrator jar to download

		## Hello World Workflow
		1. Clone dockers repo
		2. Go to investigation-integrator folder
		3. Build the image using :
			> ./buildDockerImage.sh -t inv-test --imageData ./imageData/latest.json  --uri http://dev-nexus.fircosoft.net/content/sites/site-3rd-parties/decision-insight/2.0.0/simulators-1.0.0.jar
			Verify that the image was successfully created using : 
			    > docker image ls
		4. Run the container using :
			> docker run --name inv-test-container -p 8111:8111 -it -d inv-test
			Verify that the container is running using :
			    > docker container ps
		5. Verify that the investigation integrator sping boot application is up and running by checking the container logs using :
			> docker logs inv-test-container

		## How to run the image
		docker run --name container-name -p 8111:8111 -it -d image-name


## How to build the image from dependencies
You can use the [buildDockerImageFromDependencies.sh] script to build the image from its dependencies using an image data file name that links to related references with minimum input parameter
 
$ ./buildDockerImage.sh --imageData image-data-file-name
    Parameters:
       --imageData            : Image data file name contained under imageData folder, file extension should not be provided

As image name and package uri are not provided, default values declared in imageData file and references files will be used.


		# Hello World Workflow
			1. Clone dockers repo
			2. Go to investigation-integrator folder
			3. Build the image using :
				> ./buildDockerImageFromDependencies.sh --imageData latest
				Verify that the image was successfully created using : 
				    > docker image ls
			4. Run the container using : (change command if image name has changed)
				> docker run --name investigation-integrator-container -p 8111:8111 -it -d investigation-integrator 
				Verify that the container is running using :
				    > docker container ps
			5. Verify that the investigation integrator sping boot application is up and running by checking the container logs using :
				> docker logs investigation-integrator-container

		## How to run the image
			docker run --name investigation-integrator-container -p 8111:8111 -it -d investigation-integrator 

# Keep in mind
The keystores are created under the jks folder : the client keystore should be referenced in continuity configuration to be used when communicating with the investigation integrator web service
The server certificate is generated using the build machine ip (hostname -i) as CN, this same ip should be used in continuity configuration to communicate with the investigation integrator. 
The build machine ip is shown in logs when building the docker image : "IP that should be used to target the investigation integrator is : " $(hostname -i)

