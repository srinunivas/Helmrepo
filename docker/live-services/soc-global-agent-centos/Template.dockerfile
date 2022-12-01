# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-global-agent.product}}"
LABEL asset "{{deps.ls-global-agent.asset}}"
LABEL version "{{deps.ls-global-agent.version}}"

ENV LS_HOME=/LiveServices

# Download admin zip
# Untar admin
# ----------
#USER continuity
COPY {{deps.ls-global-agent.installpath}} $LS_HOME/
WORKDIR $LS_HOME/GlobalAgent/bin
RUN ["chmod", "+x", "Start_GlobalAgent.sh"]
CMD ./Start_GlobalAgent.sh -i