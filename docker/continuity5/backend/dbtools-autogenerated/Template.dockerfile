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
ENV DBTOOLS_PRODUCT={{deps.dbtools.product}}
ENV DBTOOLS_ASSET={{deps.dbtools.asset}}
ENV DBTOOLS_VERSION={{deps.dbtools.version}}

RUN echo DBTOOLS_URI={{deps.dbtools.uri}}
RUN echo DBTOOLS_VERSION=$DBTOOLS_VERSION


# Untar dbtools
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft {{deps.dbtools.installpath}} $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft setupDBTools.sh setupDBTools.sh
COPY --chown=continuity:fircosoft start.sh start.sh
COPY --chown=continuity:fircosoft start_Import.sh $CONTINUITY_HOME/backend/start_Import.sh


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
CMD $CONTINUITY_HOME/backend/start_Import.sh
