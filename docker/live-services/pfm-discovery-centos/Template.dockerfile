# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-pfm-discovery.product}}"
LABEL asset "{{deps.ls-pfm-discovery.asset}}"
LABEL version "{{deps.ls-pfm-discovery.version}}"

ENV LS_HOME=/LiveServices

# Download discovery zip
# Untar discovery
# ----------
#USER continuity
COPY {{deps.ls-pfm-discovery.installpath}} $LS_HOME/


WORKDIR $LS_HOME/Discovery/bin
RUN ["chmod", "+x", "Start_Discovery.sh"]
CMD ./Start_Discovery.sh -i

