# Pull base image
# ---------------
FROM tomcat:8.5

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


# Copy context.xml template
# ----------
ADD conf/context.xml ${CATALINA_HOME}/conf/context.xml

#add docker-entrypoint.sh 
COPY conf/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 655 /docker-entrypoint.sh
#add ojdbc driver for oracle
ADD http://dev-nexus.fircosoft.net/service/local/repositories/central/content/com/oracle/ojdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar  /usr/local/tomcat/lib/ojdbc8-19.3.0.0.jar 
RUN chmod 644 /usr/local/tomcat/lib/ojdbc8-19.3.0.0.jar
#add continuity war 
COPY {{deps.webui.installpath}}/*.war /usr/local/tomcat/webapps/continuity.war

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
   