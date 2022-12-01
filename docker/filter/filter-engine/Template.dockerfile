FROM oraclelinux:7
LABEL maintainer "DevOps <devops@accuity.com>"
# Get main information directly from imageData info
# -------------------------------------------------
LABEL product "{{product}}"
LABEL asset "{{asset}}"
LABEL version "{{version}}"

# Get push information directly from artifact
# -------------------------------------------
LABEL push "{{deps.filter-engine.push}}"

# Copy imageData configuration file
#  and dependencies configuration files in the image itself
# ---------------------------------------------------------
ADD {{deps.filter-engine.uri}} /
RUN tar -zxf *.tar.gz

RUN useradd -ms /bin/bash firco \
  && usermod -aG root firco

USER firco
# Run FOFSERV
# ----------------------------------------------------------
ENTRYPOINT ["/FOFSERV"]