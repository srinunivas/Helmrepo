FROM centos:7
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
RUN yum install -y glibc libstdc++ && \
    yum install -y https://cbs.centos.org/kojifiles/packages/dumb-init/1.2.2/6.el8/x86_64/dumb-init-1.2.2-6.el8.x86_64.rpm && \
    yum clean all

ADD {{deps.filter-engine.uri}} /

WORKDIR /fircosoft
RUN tar -zxf ../*.tar.gz

RUN ln -s /fircosoft/shared/fof.cf /fircosoft/fof.cf

RUN useradd -ms /bin/bash firco \
  && usermod -aG root firco

USER firco
# Run FOFSERV
# ----------------------------------------------------------
ENTRYPOINT ["/usr/bin/dumb-init", "./FOFSERV"]
