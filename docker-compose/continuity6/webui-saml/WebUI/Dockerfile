# Pull base image
# ---------------
FROM tomcat:8.5

ARG WEBUI_NEXUS_PATH

# Copy context.xml, server.xml, keystore.jks template
# ----------
ADD conf/context.xml ${CATALINA_HOME}/conf/context.xml
ADD conf/server.xml ${CATALINA_HOME}/conf/server.xml
ADD conf/keystore.jks ${CATALINA_HOME}/conf/keystore.jks

#add docker-entrypoint.sh
COPY conf/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod 655 /docker-entrypoint.sh
#add ojdbc driver for oracle
ADD http://dev-nexus.fircosoft.net/service/local/repositories/central/content/com/oracle/ojdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar  /usr/local/tomcat/lib/ojdbc8-19.3.0.0.jar
RUN chmod 644 /usr/local/tomcat/lib/ojdbc8-19.3.0.0.jar
#add continuity war
RUN mkdir /tmp/cty_tmp
RUN wget ${WEBUI_NEXUS_PATH} -O /tmp/cty_tmp/continuity.zip
RUN unzip /tmp/cty_tmp/continuity.zip -d /tmp/cty_tmp/
RUN cp /tmp/cty_tmp/*.war /usr/local/tomcat/webapps/continuity.war

RUN mkdir -p /tmp/WEB-INF/classes/
RUN mkdir -p /tmp/WEB-INF/classes/security
COPY conf/configuration.properties /tmp/WEB-INF/classes/
COPY conf/keystore.jks /tmp/WEB-INF/classes/security/
COPY conf/descriptor.xml /tmp/WEB-INF/classes/security/

RUN cd /tmp && jar -uf /usr/local/tomcat/webapps/continuity.war WEB-INF/classes/configuration.properties
RUN cd /tmp && jar -uf /usr/local/tomcat/webapps/continuity.war WEB-INF/classes/security/keystore.jks
RUN cd /tmp && jar -uf /usr/local/tomcat/webapps/continuity.war WEB-INF/classes/security/descriptor.xml
EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
