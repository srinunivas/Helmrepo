# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-pfm-reporting.product}}"
LABEL asset "{{deps.ls-pfm-reporting.asset}}"
LABEL version "{{deps.ls-pfm-reporting.version}}"

ENV LS_HOME=/LiveServices

# Download reporting zip
# Untar reporting
# ----------
#USER continuity
COPY {{deps.ls-pfm-reporting.installpath}} $LS_HOME/


WORKDIR $LS_HOME/Reporting/bin
RUN ["chmod", "+x", "Start_Reporting.sh"]
CMD ./Start_Reporting.sh -i

