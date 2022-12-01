# Pull base image
# ---------------
FROM {{deps.fircosoftBase.name}} as base

## Update base with what is needed to build this docker
## ----------
USER root
RUN yum install -y \
	deltarpm \
	unzip \
	libunwind \
	libicu \
	gettext \
	libcurl-devel \
	openssl-devel \
	zlib \
	libicu-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

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
LABEL push "{{deps.erf.version}}-oel7"

# Copy imageData configuration file
#  and dependencies configuration files in the image itself
# ---------------------------------------------------------
COPY {{imageDataPath}} /imageData

RUN mkdir -p /usr/local/erf

ADD {{deps.erf.uri}} /tmp/erf/samnet.zip

ADD http://dev-nexus.fircosoft.net/content/sites/site-deployconfigs/ERF/beta/config.zip /tmp/erf/config.zip

ADD http://dev-nexus.fircosoft.net/content/sites/site-deployconfigs/ERF/beta/License.license /tmp/erf/License.license

RUN mkdir -p /tmp/erf && unzip /tmp/erf/samnet.zip -d /tmp/erf

RUN mkdir -p /tmp/config && unzip /tmp/erf/config.zip -d /tmp/config

RUN mkdir -p /tmp/license && cp /tmp/erf/License.license -d /tmp/license/License.license

RUN cp -R $(find /tmp/erf -type d -name netcoreapp3.1)/ /usr/local/erf

RUN cp -R /tmp/config /usr/local/erf/netcoreapp3.1

RUN cp -R /tmp/license /usr/local/erf/netcoreapp3.1

RUN rm -Rf /tmp/erf \
	rm -Rf /tmp/config \
	rm -Rf /tmp/license

RUN chmod +x /usr/local/erf/netcoreapp3.1/SafeAlert.SamNet.Console

WORKDIR /usr/local/erf/netcoreapp3.1

EXPOSE 3467

CMD ./SafeAlert.SamNet.Console \
--servicename erfservice \
--logfolder logfolder \
--loglevel verbose \
--licensesearchpath license/ \
--port 3467 \
--settingsfile config/alertSettings.json

# Healtchcheck command. 
HEALTHCHECK --interval=15s --timeout=15s CMD [ "200" = "$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3467/api/v2/heartbeat)" ] || exit 1