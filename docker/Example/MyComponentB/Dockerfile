FROM httpd:2.4
LABEL maintainer "DevOps <devops@accuity.com>"
LABEL product "Example"
LABEL asset "MyComponentB"
LABEL version "1.0"
LABEL push "xx"

## Update base with what is needed to build this docker
## ----------

# Arguments that need to be set outside dockerfle before building
# Variables not available on container
# ----------
ARG IMAGE_DATA_FILE

RUN echo IMAGE_DATA_FILE=$IMAGE_DATA_FILE

# Copy reference files to trigger rebuild upon change
# ----------
USER root
RUN mkdir -p /imageData/images
RUN mkdir -p /imageData/artifacts
COPY $IMAGE_DATA_FILE          /imageData/imageData.json
COPY ./imageData/images/       /imageData/images/
COPY ./imageData/artifacts/    /imageData/artifacts/


# Get package content
# ------------------
COPY ./references/Example-MyComponentB-latest/*.html /usr/local/apache2/htdocs/