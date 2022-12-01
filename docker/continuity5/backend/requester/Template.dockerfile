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
ENV REQUESTER_PRODUCT={{deps.requester.product}}
ENV REQUESTER_ASSET={{deps.requester.asset}}
ENV REQUESTER_VERSION={{deps.requester.version}}

RUN echo REQUESTER_URI={{deps.requester.uri}}
RUN echo REQUESTER_VERSION=$REQUESTER_VERSION

ENV FILTER_PRODUCT={{deps.filter.product}}
ENV FILTER_ASSET={{deps.filter.asset}}
ENV FILTER_VERSION={{deps.filter.version}}

RUN echo FILTER_URI={{deps.filter.uri}}
RUN echo FILTER_VERSION=$FILTER_VERSION


# Copy reference files to trigger rebuild upon change
# ----------
USER root
COPY {{imageDataPath}} /imageData


# Untar requester
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
RUN echo Untarring {{deps.requester.uri}} in $CONTINUITY_HOME/backend
RUN curl -SL {{deps.requester.uri}} | tar -xzC $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft setupRequester.sh setupRequester.sh
COPY --chown=continuity:fircosoft start.sh start.sh
COPY --chown=continuity:fircosoft startRequester.sh $CONTINUITY_HOME/backend/startRequester.sh


# Untar fof
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN echo Untarring {{deps.filter.uri}} in $CONTINUITY_HOME/backend/FilterEngine
RUN curl -SL {{deps.filter.uri}} | tar -xzC $CONTINUITY_HOME/backend/FilterEngine
COPY --chown=continuity:fircosoft setupFilter.sh setupFilter.sh


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


# Create volume to handle resources for requester such as licence files
# ----------
VOLUME $CONTINUITY_HOME/resources/$REQUESTER_PRODUCT/licence
VOLUME $CONTINUITY_HOME/resources/$REQUESTER_PRODUCT/config


# Create volume to handle resources for filter such as licence, kz and res files
# ----------
VOLUME $CONTINUITY_HOME/resources/$FILTER_PRODUCT


# Start container command
# ----------
ENTRYPOINT [ "./start.sh" ]
CMD $CONTINUITY_HOME/backend/startRequester.sh
