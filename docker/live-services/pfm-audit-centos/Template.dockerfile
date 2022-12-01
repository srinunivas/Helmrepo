# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-pfm-audit.product}}"
LABEL asset "{{deps.ls-pfm-audit.asset}}"
LABEL version "{{deps.ls-pfm-audit.version}}"

ENV LS_HOME=/LiveServices

# Download audit zip
# Untar audit
# ----------
#USER continuity
COPY {{deps.ls-pfm-audit.installpath}} $LS_HOME/


WORKDIR $LS_HOME/Audit/bin
RUN ["chmod", "+x", "Start_Audit.sh"]
CMD ./Start_Audit.sh -i

