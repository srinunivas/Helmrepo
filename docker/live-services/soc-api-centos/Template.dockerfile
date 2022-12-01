# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-soc-api.product}}"
LABEL asset "{{deps.ls-soc-api.asset}}"
LABEL version "{{deps.ls-soc-api.version}}"

ENV LS_HOME=/LiveServices

# Download ls-api zip
# Untar ls-api
# ----------
#USER continuity
COPY {{deps.ls-soc-api.installpath}} $LS_HOME/

WORKDIR $LS_HOME/LS-API/bin
RUN ["chmod", "+x", "Start_LS-API.sh"]
CMD ./Start_LS-API.sh -i


