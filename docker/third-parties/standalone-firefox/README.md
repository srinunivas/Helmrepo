# Selenium Standalone Firefox ESR images

This is a Firefox ESR build from the official 
[SeleniumHQ/docker-selenium repository](https://github.com/SeleniumHQ/docker-selenium).

## Usage

1. Start a Docker container with Firefox

  ```sh
  $ docker run -d -p 4444:4444 -p 7900:7900 --shm-size 2g \
      jenkins-deploy.fircosoft.net/third-parties/selenium/standalone-firefox:78.11.0esr
  # OR
  $ docker run -d -p 4444:4444 -p 7900:7900 -v /dev/shm:/dev/shm \
      jenkins-deploy.fircosoft.net/third-parties/selenium/standalone-firefox:78.11.0esr
  ```

2. Point your WebDriver tests to http://localhost:4444 *

3. That's it!

4. (Optional) To see what is happening inside the container, head to http://localhost:7900
  (password is secret).

- Grid 3 used "/wd/hub", while it should also work, it is no longer required

More details about visualising the container activity, check the 
[Debugging](https://github.com/SeleniumHQ/docker-selenium#debugging) section.

> When executing docker run for an image that contains a browser please either
  mount `-v /dev/shm:/dev/shm` or use the flag `--shm-size=2g` to use the
  host's shared memory.

> Always use a Docker image with a full tag to pin a specific browser and Grid
  version. See [Tagging Conventions](https://github.com/SeleniumHQ/docker-selenium/wiki/Tagging-Convention)
  for details.

**References**

- Official Docker Hub page: https://hub.docker.com/r/selenium/standalone-firefox
- Official Usage Documentation: https://github.com/SeleniumHQ/docker-selenium#quick-start
