# Pull base image
# ---------------
FROM {{deps.weblogic.name}}

# Maintainer
# ----------
LABEL maintainer="RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"

# Get main information directly from imageData info
# -------------------------------------------------
LABEL product="{{product}}"
LABEL asset="{{asset}}"
LABEL version="{{deps.webui.version}}"

# Get push information directly from artifact
# -------------------------------------------
LABEL push="{{deps.webui.push}}"

ENV DOMAIN_NAME base_domain

ENV WEBAPPS_LOCATION /u01/oracle/webapps
RUN mkdir ${WEBAPPS_LOCATION}

# Copy imageData configuration file
#  and dependencies configuration files in the image itself
# ---------------------------------------------------------
COPY {{imageDataPath}} /imageData

#add continuity war
COPY {{deps.webui.installpath}}/*.war ${WEBAPPS_LOCATION}/continuity.war

COPY ./scripts/* /u01/oracle/  

ADD --chown=oracle:oracle {{deps.mssqlJdbc.uri}} /u01/oracle/wlserver/server/lib/{{deps.mssqlJdbc.filename}}

COPY domain.properties /u01/oracle/properties/domain.properties


CMD ["/u01/oracle/start.sh"]

HEALTHCHECK --interval=60s --timeout=60s --retries=10 \
  CMD curl -f http://localhost:7001/continuity || exit 1

