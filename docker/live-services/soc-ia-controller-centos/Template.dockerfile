# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-ia-controller.product}}"
LABEL asset "{{deps.ls-ia-controller.asset}}"
LABEL version "{{deps.ls-ia-controller.version}}"

ENV LS_HOME=/LiveServices

# Download admin zip
# Untar admin
# ----------
#USER continuity
COPY {{deps.ls-ia-controller.installpath}} $LS_HOME/

COPY {{deps.filter.installpath}} $LS_HOME/FilterEngine

WORKDIR $LS_HOME/IAController/impact-assessment
RUN ["chmod", "+x", "runImpactAssessment.sh"]
RUN ["chmod", "+x", "stopImpactAssessment.sh"]

WORKDIR $LS_HOME/IAController/impact-assessment/scripts
RUN ["chmod", "+x", "filter-stop.sh"]
RUN ["chmod", "+x", "filter-ping.sh"]

WORKDIR $LS_HOME/IAController/bin
RUN ["chmod", "+x", "Start_IAController.sh"]
CMD ./Start_IAController.sh -i