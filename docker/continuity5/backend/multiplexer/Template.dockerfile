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


# Copy reference files to trigger rebuild upon change
# ----------
USER root
COPY {{imageDataPath}} /imageData


# Untar multiplexer
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
RUN echo Untarring {{deps.multiplexer.uri}} in $CONTINUITY_HOME/backend
RUN curl -SL {{deps.multiplexer.uri}} | tar -xzC $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft setupMultiplexer.sh setupMultiplexer.sh
COPY --chown=continuity:fircosoft start.sh start.sh
COPY --chown=continuity:fircosoft startMultiplexer.sh $CONTINUITY_HOME/backend/startMultiplexer.sh


# Untar fircocontractmapper
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
RUN echo Untarring {{deps.fircocontractmapper.uri}} in $CONTINUITY_HOME/backend
RUN curl -SL {{deps.fircocontractmapper.uri}} | tar -xzC $CONTINUITY_HOME/backend


# Untar jsonutilities
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
RUN echo Untarring {{deps.jsonutilities.uri}} in $CONTINUITY_HOME/backend
RUN curl -SL {{deps.jsonutilities.uri}} | tar -xzC $CONTINUITY_HOME/backend


# Untar mappinghttpstatus
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
RUN echo Untarring {{deps.mappinghttpstatus.uri}} in $CONTINUITY_HOME/backend
RUN curl -SL {{deps.mappinghttpstatus.uri}} | tar -xzC $CONTINUITY_HOME/backend


# Untar mappingcasemanagerapi
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
RUN echo Untarring {{deps.mappingcasemanagerapi.uri}} in $CONTINUITY_HOME/backend
RUN curl -SL -u firco:secret135 {{deps.mappingcasemanagerapi.uri}} | tar -xzC $CONTINUITY_HOME/backend


# Create volume to handle resources such as licence files
# ----------
VOLUME $CONTINUITY_HOME/resources/$MULTIPLEXER_PRODUCT/licence
VOLUME $CONTINUITY_HOME/resources/$MULTIPLEXER_PRODUCT/config


# Start container command
# ----------
ENTRYPOINT [ "./start.sh" ]
CMD $CONTINUITY_HOME/backend/startMultiplexer.sh
