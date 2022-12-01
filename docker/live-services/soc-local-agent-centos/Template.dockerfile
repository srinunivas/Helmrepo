# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-local-agent.product}}"
LABEL asset "{{deps.ls-local-agent.asset}}"
LABEL version "{{deps.ls-local-agent.version}}"

ENV LS_HOME=/LiveServices

# Download admin zip
# Untar admin
# ----------
#USER continuity
COPY {{deps.ls-local-agent.installpath}} $LS_HOME/
WORKDIR $LS_HOME/LocalAgent/bin
RUN ["chmod", "+x", "Start_LocalAgent.sh"]
CMD ./Start_LocalAgent.sh -i