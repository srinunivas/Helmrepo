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
ARG REQUESTER_URI
ARG REQUESTER_VERSION

RUN echo IMAGE_DATA_FILE=$IMAGE_DATA_FILE
RUN echo REQUESTER_URI=$REQUESTER_URI
RUN echo REQUESTER_VERSION=$REQUESTER_VERSION


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
ENV REQUESTER_PRODUCT=Continuity
ENV REQUESTER_VERSION=$REQUESTER_VERSION


# Untar requester
# ----------
USER continuity
WORKDIR $CONTINUITY_HOME
RUN mkdir -p $CONTINUITY_HOME/backend
RUN echo Untarring $REQUESTER_URI in $CONTINUITY_HOME/backend
RUN curl -SL $REQUESTER_URI | tar -xzC $CONTINUITY_HOME/backend
COPY --chown=continuity:fircosoft start.sh start.sh
COPY --chown=continuity:fircosoft startRequester.sh $CONTINUITY_HOME/backend/startRequester.sh


# Create FilterEngine directory
# ----------
RUN mkdir -p $CONTINUITY_HOME/backend/FilterEngine



# Start container command
# ----------
ENTRYPOINT [ "./start.sh" ]
CMD [ "ping", "localhost", "-i", "60" ]
