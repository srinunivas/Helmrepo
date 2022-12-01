Please see also the [Shadoker usage for development teams](http://confluence.fircosoft.net/display/DTP/Shadoker+usage+for+development+teams) page on Confluence for additional information and examples.

## Directory `references/`
This is the root folder where all references are defined.
Each definition consists of a single JSON file.
It contains two types of references which can be found in two sub-folders.
### Directory `references/artifacts`
These references point to packages, binary, jar, zip or any type of file, stored in binary repository like Nexus.
Sample:
```
{
    "artifact": {
        "name": "CoreEngine-5.6.5.8-develop-5.6.5.x-linux",
        "buildDate": "23/02/2020",
        "commit": "0b7744cb9d6",
        "uri": "http://dev-nexus.fircosoft.net/content/sites/site-builds/CoreEngine/5.6.5.8.p2-develop-5.6.5.x/CoreEngine32-5.6.5.8.p2-linux.tar.gz",
        "product": "CoreEngine",
        "prefix": "develop-5.6.5.x",
        "version": "5.6.5.8",
        "push": "p2",
        "comment": "This is version 5.6.5.8.p2 of CoreEngine"
    }
}
```

### Directory `references/images`
These references point to existing Docker images in a Docker registry like Portus
Sample:
```
{
    "image": {
        "buildDate": "23/02/2020",
        "commit": "0b7744cb9d6",
        "name": "jenkins-deploy.fircosoft.net/continuity5/filterengine-oraclelinux:5.7.5.2"
    }
}
```

## Directory `docker/`

## The `shadoker` CLI tool
This Python 3 command-line tool is used to manage most of the operations on the above directories and files.

### Installation
It requires Python 3.6, installation can be done:
```
pip3 install -r shadoker/requirements.txt
```

### Usage
Type `shadoker help` to get the list of available commands.


### Sample commands
List all modified package definitions since previous commit, including locally modified ones (unstaged changes)
```
> shadoker-cli package ls -s HEAD~1 -t
```
List all Docker image definitions with possible errors
```
> shadoker-cli docker ls -w
```

Update a specified package to a new version
```
> shadoker-cli package update -u "{\"push\":\"p3\",\"uri\":\"http://.../ContinuityRequester-5.3.17.7.3-linux.tar.gz\",\"comment\":\"Release p3 of Requester\"}" Continuity-5.3.17.7-release-5.3.17.x-ContinuityRequester-linux
```


