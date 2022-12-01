# Unique Filter Dockerfile

This directory houses the unique filter Dockerfile

## Running Locally Built Images

After building the image with the tag `unique-filter` (for example), use `docker run` to run the images.

By default the filter will use a standard configuration and load the `FOFDB.kz`, `fkof.res` and `fof.cf` files that need to be provided in the directory `/filter-conf/`.  
In the default configuration, the filter log will be written in `/filter-conf/uniquefilter.log`.  
A custom filter configuration can be provided in the file `/filter-conf/config.json`.

The nginx configuration can be customized by using the `-c` option : `-c /filter-conf/nginx.conf`.

Note for new Docker users: the `-v` and `-u` flags share directories and
permissions between the Docker container and your machine and `-p` is used to map the port.
[Docker run documentation](https://docs.docker.com/engine/reference/run/) for
more info.

```bash
# in a directory containing the require file

# default nginx configuration
docker run -u $(id -u):$(id -g) -v `pwd`:/filter-conf -p8080:80 --rm -d unique-filter

# overriding the default configuration
docker run -u $(id -u):$(id -g) -v `pwd`:/filter-conf -p8080:80 --rm -d unique-filter -c /filter-conf/nginx.conf
```