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
        gzip \
        iputils \
        tar


# Arguments that need to be set outside dockerfle before building
# Variables not available on container
# ----------
ARG IMAGE_DATA_FILE
ARG FILTERENGINE_URI
ARG FILTERENGINE_VERSION

RUN echo IMAGE_DATA_FILE=$IMAGE_DATA_FILE
RUN echo FILTERENGINE_URI=$FILTERENGINE_URI
RUN echo FILTERENGINE_VERSION=$FILTERENGINE_VERSION


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV FILTERENGINE_PRODUCT=filter
ENV FILTERENGINE_VERSION=$FILTERENGINE_VERSION


# Copy reference files to trigger rebuild upon change
# ----------
USER root
RUN mkdir -p /imageData/images
RUN mkdir -p /imageData/artifacts
COPY $IMAGE_DATA_FILE          /imageData/imageData.json
COPY ./imageData/images/       /imageData/images/
COPY ./imageData/artifacts/    /imageData/artifacts/


# Untar fof
# ----------
USER filter
WORKDIR $FILTER_HOME
RUN mkdir $FILTER_HOME/fof
RUN echo Untarring $FILTERENGINE_URI in $FILTER_HOME/fof
RUN curl -SL $FILTERENGINE_URI | tar -xzC $FILTER_HOME/fof
COPY --chown=filter:fircosoft start.sh start.sh


# Make volume for resources
# ----------
RUN mkdir $FILTER_HOME/resources
VOLUME [ "$FILTER_HOME/resources" ]


# Start container command
# ----------
ENTRYPOINT [ "./start.sh" ]
CMD [ "ping", "localhost", "-i", "60" ]
