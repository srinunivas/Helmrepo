# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-wlm-web.product}}"
LABEL asset "{{deps.ls-wlm-web.asset}}"
LABEL version "{{deps.ls-wlm-web.version}}"

ARG MAIN_ARTIFACT_URI
ENV LS_HOME=/LiveServices

# Download wlm-api zip
# Untar wlm-web
# ----------
COPY {{deps.ls-wlm-web.installpath}} $LS_HOME/

WORKDIR $LS_HOME/WLM-Web/bin
RUN ["chmod", "+x", "Start_WLM-Web.sh"]
CMD ./Start_WLM-Web.sh -i
