# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-pfm-referential.product}}"
LABEL asset "{{deps.ls-pfm-referential.asset}}"
LABEL version "{{deps.ls-pfm-referential.version}}"

ENV LS_HOME=/LiveServices

# Download referential zip
# Untar referential
# ----------
#USER continuity
COPY {{deps.ls-pfm-referential.installpath}} $LS_HOME/


WORKDIR $LS_HOME/Referential/bin
RUN ["chmod", "+x", "Start_Referential.sh"]
CMD ./Start_Referential.sh -i

