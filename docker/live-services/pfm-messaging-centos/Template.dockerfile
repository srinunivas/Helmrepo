# Pull base image
# ---------------
FROM adoptopenjdk/openjdk8:centos-slim

# Maintainer
# ----------
LABEL maintainer "Glauber ARAUJO <glauber.araujo@accuity.com>"
LABEL product "{{deps.ls-pfm-messaging.product}}"
LABEL asset "{{deps.ls-pfm-messaging.asset}}"
LABEL version "{{deps.ls-pfm-messaging.version}}"

ENV LS_HOME=/LiveServices

# Download messaging zip
# Untar messaging
# ----------
#USER continuity
COPY {{deps.ls-pfm-messaging.installpath}} $LS_HOME/


WORKDIR $LS_HOME/Messaging/bin
RUN ["chmod", "+x", "Start_Messaging.sh"]
CMD ./Start_Messaging.sh -i

