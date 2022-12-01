# Pull base image
# ---------------
FROM {{deps.fircobase.name}} as base


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


## Update base with what is needed to build this docker
## ----------
USER root
RUN yum install -y \
        glibc.i686 \
        gzip \
        iputils \
        libstdc++.i686 \
        tar


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV COREENGINE_PRODUCT={{deps.coreengine.product}}
ENV COREENGINE_ASSET={{deps.coreengine.asset}}
ENV COREENGINE_VERSION={{deps.coreengine.version}}

RUN echo COREENGINE_URI={{deps.coreengine.uri}}
RUN echo COREENGINE_VERSION={{deps.coreengine.version}}


# Copy reference files to trigger rebuild upon change
# ----------
USER root
COPY {{imageDataPath}} /imageData


# Untar coreengine
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
RUN mkdir -p $CONTINUITY_HOME/coreengine
COPY --chown=continuity:fircosoft {{deps.coreengine.installpath}} $CONTINUITY_HOME/coreengine
COPY --chown=continuity:fircosoft setupCoreEngine.sh setupCoreEngine.sh
COPY --chown=continuity:fircosoft start.sh start.sh


# Start container command
# ----------
ENTRYPOINT [ "./start.sh", "/home/continuity/backend/bin32/linux/FKRUN" ]