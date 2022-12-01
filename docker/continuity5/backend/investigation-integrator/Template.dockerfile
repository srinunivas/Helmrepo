# Pull base image
# ---------------
FROM {{deps.fircobase.name}} as base


# Maintainer
# ----------
LABEL maintainer="Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


## Update base with what is needed to build this docker
## ----------
USER root
RUN yum install -y \
        java

# Copy reference files to trigger rebuild upon change
# ----------
USER root
COPY {{imageDataPath}} /imageData


# Deploy Investigation Integrator
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME

RUN mkdir -p $CONTINUITY_HOME/investigationIntegrator/logs
RUN mkdir -p $CONTINUITY_HOME/investigationIntegrator/jks
RUN mkdir -p $CONTINUITY_HOME/investigationIntegrator/inputs
RUN mkdir -p $CONTINUITY_HOME/investigationIntegrator/config
RUN mkdir -p $CONTINUITY_HOME/investigationIntegrator/script
RUN mkdir -p $CONTINUITY_HOME/compliance/input

COPY --chown=continuity:fircosoft ./jks                  $CONTINUITY_HOME/investigationIntegrator/jks
COPY --chown=continuity:fircosoft ./config               $CONTINUITY_HOME/investigationIntegrator/config
COPY --chown=continuity:fircosoft ./script               $CONTINUITY_HOME/investigationIntegrator/script
COPY --chown=continuity:fircosoft ./inputs               $CONTINUITY_HOME/investigationIntegrator/inputs
COPY --chown=continuity:fircosoft ./compliance/input     $CONTINUITY_HOME/compliance/input

#RUN cd $CONTINUITY_HOME/investigationIntegrator  && { curl -SLO $INVESTIGATION_INTEGRATOR_URI ; }
ADD --chown=continuity:fircosoft {{deps.main.uri}} $CONTINUITY_HOME/investigationIntegrator


# Expose ports
# ----------
EXPOSE 8111
EXPOSE 8112


# Start container command
# ----------
#CMD [ "java", "-jar", "$CONTINUITY_HOME/investigationIntegrator/simulators-1.0.0.jar", "--spring.config.location=file://$CONTINUITY_HOME/investigationIntegrator/config/application.properties" ]
CMD [ "investigationIntegrator/script/startServer.sh" ]