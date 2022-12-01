# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-wlm-api.product}}"
LABEL asset "{{deps.ls-wlm-api.asset}}"
LABEL version "{{deps.ls-wlm-api.version}}"

ARG MAIN_ARTIFACT_URI
ENV LS_HOME=/LiveServices

# Download wlm-api zip
# Untar wlm-api
# ----------
COPY {{deps.ls-wlm-api.installpath}} $LS_HOME/

# Download wlm-config zip
# Untar wlm-config
# ----------
COPY {{deps.ls-wlm-config.installpath}} $LS_HOME/

WORKDIR $LS_HOME/WLM-Api/bin
RUN ["chmod", "+x", "Start_WLM-Api.sh"]
CMD ./Start_WLM-Api.sh -i
