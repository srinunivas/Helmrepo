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
ENV MULTIPLEXER_PRODUCT={{deps.multiplexer.product}}
ENV MULTIPLEXER_ASSET={{deps.multiplexer.asset}}
ENV MULTIPLEXER_VERSION={{deps.multiplexer.version}}

RUN echo MULTIPLEXER_URI={{deps.multiplexer.uri}}
RUN echo MULTIPLEXER_VERSION=$MULTIPLEXER_VERSION


# Untar multiplexer
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft {{deps.multiplexer.installpath}} $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft setupMultiplexer.sh setupMultiplexer.sh
COPY --chown=continuity:fircosoft start.sh start.sh
COPY --chown=continuity:fircosoft startMultiplexer.sh $CONTINUITY_HOME/backend/startMultiplexer.sh


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


# Untar mappingxmluniversal
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft {{deps.mappingxmluniversal.installpath}} $CONTINUITY_HOME/backend


# Create volume to handle resources such as licence files
# ----------
RUN mkdir -p $CONTINUITY_HOME/resources/$DBCLIENT_PRODUCT/licence \
  && chown -R continuity:fircosoft $CONTINUITY_HOME/resources/$DBCLIENT_PRODUCT/licence
VOLUME $CONTINUITY_HOME/resources/$DBCLIENT_PRODUCT/licence

RUN mkdir -p $CONTINUITY_HOME/resources/$DBCLIENT_PRODUCT/config \
  && chown -R continuity:fircosoft $CONTINUITY_HOME/resources/$DBCLIENT_PRODUCT/config
VOLUME $CONTINUITY_HOME/resources/$DBCLIENT_PRODUCT/config


# Start container command
# ----------
ENTRYPOINT [ "./start.sh" ]
CMD $CONTINUITY_HOME/backend/startMultiplexer.sh
