# Pull base image
# ---------------
ARG FIRCOSOFT_BASE_IMAGE
FROM $FIRCOSOFT_BASE_IMAGE as base


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


## Update base with what is needed to build this docker
## ----------
USER root
RUN yum install -y \
        iputils \
        tar


# Arguments that need to be set outside dockerfle before building
# Variables not available on container
# ----------
ARG IMAGE_DATA_FILE
ARG MULTIPLEXER_URI
ARG MULTIPLEXER_VERSION

RUN echo IMAGE_DATA_FILE=$IMAGE_DATA_FILE
RUN echo MULTIPLEXER_URI=$MULTIPLEXER_URI
RUN echo MULTIPLEXER_VERSION=$MULTIPLEXER_VERSION


# Copy reference files to trigger rebuild upon change
# ----------
USER root
RUN mkdir -p /imageData/images
RUN mkdir -p /imageData/artifacts
COPY $IMAGE_DATA_FILE          /imageData/imageData.json
COPY ./imageData/images/       /imageData/images/
COPY ./imageData/artifacts/    /imageData/artifacts/


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV MULTIPLEXER_PRODUCT=Continuity
ENV MULTIPLEXER_VERSION=$MULTIPLEXER_VERSION


# Untar multiplexer
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
RUN echo Untarring $MULTIPLEXER_URI in $CONTINUITY_HOME/backend
RUN curl -SL $MULTIPLEXER_URI | tar -xzC $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft start.sh start.sh
COPY --chown=continuity:fircosoft startMultiplexer.sh $CONTINUITY_HOME/backend/startMultiplexer.sh



# Start container command
# ----------
ENTRYPOINT [ "./start.sh" ]
CMD [ "ping", "localhost", "-i", "60" ]
