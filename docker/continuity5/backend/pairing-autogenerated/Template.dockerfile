# Pull base image
# ---------------
FROM {{deps.coreengineBase.name}} as base


# Maintainer
# ----------
LABEL maintainer="Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


## Update base with what is needed to build this docker
## ----------
USER root
RUN yum install -y \
        iputils \
        tar


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV PAIRING_PRODUCT={{deps.pairing.product}}
ENV PAIRING_ASSET={{deps.pairing.asset}}
ENV PAIRING_VERSION={{deps.pairing.version}}

RUN echo PAIRING_URI={{deps.pairing.uri}}
RUN echo PAIRING_VERSION=$PAIRING_VERSION


# Untar pairing
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft {{deps.pairing.installpath}} $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft setupPairing.sh setupPairing.sh
COPY --chown=continuity:fircosoft start.sh start.sh
COPY --chown=continuity:fircosoft startPairing.sh $CONTINUITY_HOME/backend/startPairing.sh


# Untar fircocontractmapper
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft {{deps.fircocontractmapper.installpath}} $CONTINUITY_HOME/backend


# Untar jsonutilities
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft {{deps.jsonutilities.installpath}} $CONTINUITY_HOME/backend


# Untar mappinghttpstatus
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft {{deps.mappinghttpstatus.installpath}} $CONTINUITY_HOME/backend


# Untar mappingcasemanagerapi
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft {{deps.mappingcasemanagerapi.installpath}} $CONTINUITY_HOME/backend


# Create volume to handle resources such as licence files
# ----------
RUN mkdir -p $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/licence \
  && chown -R continuity:fircosoft $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/licence
VOLUME $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/licence

RUN mkdir -p $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/config \
  && chown -R continuity:fircosoft $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/config
VOLUME $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/config


# Start container command
# ----------
ENTRYPOINT [ "./start.sh" ]
CMD $CONTINUITY_HOME/backend/startPairing.sh
