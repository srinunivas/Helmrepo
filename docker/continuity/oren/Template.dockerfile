FROM ubuntu:18.04

# Get main information directly from imageData info
# -------------------------------------------------
LABEL maintainer "RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"
LABEL product "{{product}}"
LABEL asset "{{asset}}"
LABEL version "{{version}}"
LABEL push "oren-{{deps.orchestrator.push}}"

USER root

# Install required tools
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    openjdk-11-jdk


# Download & install Orchestrator artifact
ENV OREN_HOME=/usr/local/orchestrator-app
COPY {{deps.orchestrator.installpath}}/ $OREN_HOME

# Create FTP USER
RUN useradd --user-group --system --create-home app -p password \
   && echo app:password | chpasswd

# Configure orchestrator app working dir
ARG WORKDIR=/usr/local/orchestrator-app
RUN mkdir -p ${WORKDIR}/libs \
    || mkdir -p ${WORKDIR}/conf/ssl \
    || chmod -R 777 ${WORKDIR}/ || true

WORKDIR ${WORKDIR}/Orchestrator
RUN chmod +x Start_Orchestrator.sh
