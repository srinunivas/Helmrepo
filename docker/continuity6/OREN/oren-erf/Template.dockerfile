FROM ubuntu:18.04

# Get main information directly from imageData info
# -------------------------------------------------
LABEL maintainer "RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"
LABEL product "{{product}}"
LABEL asset "{{asset}}"
LABEL version "{{version}}"
LABEL push "oren-{{deps.orchestrator.push}}_erf-{{deps.erf-requester.push}}"


USER root
# 1- Install required tools
RUN apt-get update && apt-get install -y \
    ftp \
    wget \
    unzip \
    vsftpd \
    iptables \
    supervisor \
    openjdk-8-jdk

# Install JACOCO AGENT
ARG JACOCO_VERSION=0.8.5
RUN wget http://search.maven.org/remotecontent?filepath=org/jacoco/jacoco/${JACOCO_VERSION}/jacoco-${JACOCO_VERSION}.zip -O /tmp/jacoco.zip \
    && touch /tmp/jacocoagent.jar && touch /tmp/jacococli.jar \
    && unzip -p /tmp/jacoco.zip lib/jacocoagent.jar > /tmp/jacocoagent.jar \
    && unzip -p /tmp/jacoco.zip lib/jacococli.jar > /tmp/jacococli.jar

# 2. Download & install Orchestrator artifact
ENV OREN_HOME=/usr/local/orchestrator-app
COPY {{deps.orchestrator.installpath}}/ $OREN_HOME

# Configure orchestrator app working dir
RUN mkdir -p $OREN_HOME/work \
    && mkdir $OREN_HOME/work/input \
    && mkdir $OREN_HOME/work/output \
    && mkdir $OREN_HOME/work/error

# 3. Download & install erf-requester artifact zip
COPY {{deps.erf-requester.installpath}}/**/ERF-*.jar $OREN_HOME/Orchestrator/libs
RUN chmod -R 777 $OREN_HOME/Orchestrator


# 4. Configure FTP Server
RUN useradd --user-group --system --create-home app -p password \
   && echo app:password | chpasswd

RUN mv /etc/vsftpd.conf /etc/vsftpd.conf_orig
COPY setup/vsftpd.conf /etc/vsftpd.conf

WORKDIR $OREN_HOME/Orchestrator

COPY setup/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


