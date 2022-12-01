# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-soc-web.product}}"
LABEL asset "{{deps.ls-soc-web.asset}}"
LABEL version "{{deps.ls-soc-web.version}}"

ENV LS_HOME=/LiveServices

# Download ls-web zip
# Untar ls-web
# ----------
#USER continuity
COPY {{deps.ls-soc-web.installpath}} $LS_HOME/


WORKDIR $LS_HOME/LS-Web/bin
RUN ["chmod", "+x", "Start_LS-Web.sh"]
CMD ./Start_LS-Web.sh -i


