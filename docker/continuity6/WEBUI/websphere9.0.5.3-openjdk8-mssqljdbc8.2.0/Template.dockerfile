# Pull base image
# ---------------
FROM ibmcom/websphere-traditional:9.0.5.3

# Maintainer
# ----------
LABEL maintainer "RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"

# Get main information directly from imageData info
# -------------------------------------------------
LABEL product "{{product}}"
LABEL asset "{{asset}}"
LABEL version "{{deps.webui.version}}"

# Get push information directly from artifact
# -------------------------------------------
LABEL push "{{deps.webui.push}}"

# Copy imageData configuration file
#  and dependencies configuration files in the image itself
# ---------------------------------------------------------
COPY {{imageDataPath}} /imageData

#add continuity war
COPY --chown=was:0 {{deps.webui.installpath}}/*.war /work/config/continuity.war

COPY  --chown=was:0 jython/was-deploy.py /work/config/
COPY  --chown=was:0 scripts/docker-entrypoint.sh /docker-entrypoint.sh
ADD   --chown=was:0 http://dev-nexus.fircosoft.net/service/local/repositories/central/content/com/microsoft/sqlserver/mssql-jdbc/8.2.0.jre8/mssql-jdbc-8.2.0.jre8.jar  /opt/IBM/WebSphere/AppServer/lib/mssql-jdbc-8.2.0.jre8.jar 

# remove exist certificates in WebSphere 9.0.5.3 docker image and they will be regenerated automatically later to avoid certificates expired issue
RUN rm /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/config/cells/DefaultCell01/nodes/DefaultNode01/trust.p12
RUN rm /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/config/cells/DefaultCell01/nodes/DefaultNode01/key.p12

ENTRYPOINT [ "/docker-entrypoint.sh" ]
