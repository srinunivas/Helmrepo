# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-pfm-administration-web.product}}"
LABEL asset "{{deps.ls-pfm-administration-web.asset}}"
LABEL version "{{deps.ls-pfm-administration-web.version}}"

ENV LS_HOME=/LiveServices

# Download administration zip
# Untar administration
# ----------
#USER continuity
COPY {{deps.ls-pfm-administration-web.installpath}} $LS_HOME/


WORKDIR $LS_HOME/AdministrationWeb/bin
RUN ["chmod", "+x", "Start_AdministrationWeb.sh"]
CMD ./Start_AdministrationWeb.sh -i

