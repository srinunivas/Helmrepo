# Pull base image
# ---------------
FROM {{deps.fircosoftBase.name}} as base

## Update base with what is needed to build this docker
## ----------
USER root
RUN yum install -y \
        wget \
        curl \
        openssl \
        unzip \
        ca-certificates \
        openssh-server \
        openssh-clients \
        java-1.8.0-openjdk-devel \
        supervisor \
        nmon \
        jq \
        scp \
        pcre \ 
        zlib \
        rsync \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN mkdir -p /var/log/supervisord \
    && wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 \
    && chmod +x /usr/local/bin/dumb-init \
    && wget http://search.maven.org/remotecontent?filepath=org/jacoco/jacoco/0.8.5/jacoco-0.8.5.zip -O /tmp/jacoco.zip \
    && touch /tmp/jacocoagent.jar \
    && mkdir -p /usr/local/jacoco \
    && unzip -p /tmp/jacoco.zip lib/jacocoagent.jar > /usr/local/jacoco/jacocoagent.jar

# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
# ENV HPR_PRODUCT=Continuity
# ENV HPR_VERSION=$HPR_VERSION
ENV LD_LIBRARY_PATH=/usr/local/nginx/modules/

# SSH
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
    && ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa \
    && ssh-keygen -A \
    && sed -ri 's/^#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
    && echo "root:" | chpasswd

# Maintainer
# ----------
LABEL maintainer "RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"


# Get main information directly from imageData info
# -------------------------------------------------
LABEL product "{{product}}"
LABEL asset "{{asset}}"
LABEL version "{{version}}"


# Get push information directly from artifact
# -------------------------------------------
LABEL push "hpr-{{deps.hpr.push}}_uf-{{deps.uf.push}}"

# Copy imageData configuration file
#  and dependencies configuration files in the image itself
# ---------------------------------------------------------
COPY {{imageDataPath}} /imageData

# FW
COPY {{deps.uf.installpath}}/ /usr/local/nginx/

RUN mkdir -p /tmp/fw \
   && mkdir -p /tmp/fw/data \
   && mkdir -p /usr/local/nginx/conf/blue \
   && mkdir -p /usr/local/nginx/conf/green \
   && mkdir -p /usr/local/fw/work/blue \
   && mkdir -p /usr/local/fw/work/green \
   && mkdir -p /usr/local/fw/resources \
   && touch /usr/local/nginx/logs/error.log \
   && touch /usr/local/nginx/logs/info.log \
   && touch /usr/local/nginx/logs/debug.log \
   && chmod 777 -R /usr/local/nginx/logs \
   && chmod 777 -R /usr/local/fw/resources \
   && chmod 777 /usr/local/nginx/conf/blue \
   && chmod 777 /usr/local/nginx/conf/green \
   && rm -f /usr/local/nginx/conf/nginx.conf

COPY {{deps.hpr.installpath}}/ /usr/local/

WORKDIR /usr/local/HighPerformanceRequester/

CMD ["java", "-jar", "HighPerformanceRequester.jar", "--config.file=conf/HighPerformanceRequester.properties", "--license.file=conf/fbe.cf", "--encryption.algorithm=PBEWITHMD5ANDDES", "--encryption.password=Secret", "--continuity.home=/usr/local"]

# Healtchcheck command. 
HEALTHCHECK --interval=15s --timeout=15s CMD [ "503" = "$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4444/healthcheck)" ] || exit 1