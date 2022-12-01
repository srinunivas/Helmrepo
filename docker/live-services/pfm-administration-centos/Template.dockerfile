# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-pfm-admin.product}}"
LABEL asset "{{deps.ls-pfm-admin.asset}}"
LABEL version "{{deps.ls-pfm-admin.version}}"

ENV LS_HOME=/LiveServices

# Download admin zip
# Untar admin
# ----------
#USER continuity
COPY {{deps.ls-pfm-admin.installpath}} $LS_HOME/


WORKDIR $LS_HOME/Administration/bin
RUN ["chmod", "+x", "Start_Administration.sh"]
CMD ./Start_Administration.sh -i

