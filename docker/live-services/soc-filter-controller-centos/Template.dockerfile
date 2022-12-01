# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-filter-controller.product}}"
LABEL asset "{{deps.ls-filter-controller.asset}}"
LABEL version "{{deps.ls-filter-controller.version}}"

ENV LS_HOME=/LiveServices

# Download admin zip
# Untar admin
# ----------
#USER continuity
COPY {{deps.ls-filter-controller.installpath}} $LS_HOME/

COPY {{deps.filter.installpath}} $LS_HOME/FilterEngine

WORKDIR $LS_HOME/FilterController/deployment
RUN ["chmod", "+x", "runDeployment.sh"]

WORKDIR $LS_HOME/FilterController/deployment/fofserv
RUN ["chmod", "+x", "filter-stop.sh"]
RUN ["chmod", "+x", "filter-ping.sh"]
RUN ["chmod", "+x", "filter-start.sh"]

WORKDIR $LS_HOME/FilterController/bin
RUN ["chmod", "+x", "Start_FilterController.sh"]
CMD ./Start_FilterController.sh -i