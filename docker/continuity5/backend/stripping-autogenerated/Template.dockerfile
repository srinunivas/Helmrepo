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
ENV STRIPPING_PRODUCT={{deps.stripping.product}}
ENV STRIPPING_ASSET={{deps.stripping.asset}}
ENV STRIPPING_VERSION={{deps.stripping.version}}

RUN echo STRIPPING_URI={{deps.stripping.uri}}
RUN echo STRIPPING_VERSION=$STRIPPING_VERSION


# Untar stripping
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft {{deps.stripping.installpath}} $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft setupStripping.sh setupStripping.sh
COPY --chown=continuity:fircosoft start.sh start.sh
COPY --chown=continuity:fircosoft startStripping.sh $CONTINUITY_HOME/backend/startStripping.sh


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
RUN mkdir -p $CONTINUITY_HOME/resources/$STRIPPING_PRODUCT/licence \
  && chown -R continuity:fircosoft $CONTINUITY_HOME/resources/$STRIPPING_PRODUCT/licence
VOLUME $CONTINUITY_HOME/resources/$STRIPPING_PRODUCT/licence

RUN mkdir -p $CONTINUITY_HOME/resources/$STRIPPING_PRODUCT/config \
  && chown -R continuity:fircosoft $CONTINUITY_HOME/resources/$STRIPPING_PRODUCT/config
VOLUME $CONTINUITY_HOME/resources/$STRIPPING_PRODUCT/config


# Start container command
# ----------
ENTRYPOINT [ "./start.sh" ]
CMD $CONTINUITY_HOME/backend/startStripping.sh
