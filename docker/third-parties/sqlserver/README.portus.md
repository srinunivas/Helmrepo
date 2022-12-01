# Microsoft SQL Server Docker Image

This is a Fircosoft base image for SQL Server based on official Microsoft
SQL Server image General Availability.

Some changes from the original image have been made:

- Two important variables have been added to simplify the image ceation:
  - `$FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR`: Used as the destination of your setup
    scripts
  - `$FIRCOSOFT_DOCKER_SETUP_INIT_SCRIPT`: Used to run the SQL Server database
    initialization.

  Please check the section bellow *Usage with Dockerfile*.

- The SQL Server binary path `/opt/mssql-tools/bin` has been added to the 
  system environment variable `$PATH`. This means that you can run
  `sqlcmd` anywhere.

- Default SQL Server environments variables have been changed to follow the
  Fircosoft requirements. Please see the next section 
  (*Default Environment $Variables*) to know more abour new default SQL Server
  environments variables.

**Found the complete documentation here: [https://dev-bitbucket.fircosoft.net/projects/fir/repos/shadoker/browse/docker/third-parties/sqlserver/README.md](https://dev-bitbucket.fircosoft.net/projects/fir/repos/shadoker/browse/docker/third-parties/sqlserver/README.md)**
