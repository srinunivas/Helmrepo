FROM oraclelinux:7
LABEL maintainer "DevOps <devops@accuity.com>"
# Get main information directly from imageData info
# -------------------------------------------------
LABEL product "{{product}}"
LABEL asset "{{asset}}"
LABEL version "{{version}}"

# Get push information directly from artifact
# -------------------------------------------
LABEL push "{{deps.unifilter.push}}"

# Copy imageData configuration file
#  and dependencies configuration files in the image itself
# ---------------------------------------------------------
ADD {{deps.unifilter.uri}} /
RUN mkdir -p /uniquefilter
RUN tar -zxf *.tar.gz -C /uniquefilter
RUN ln -s /uniquefilter/data/ /data
RUN echo 'if test -e /filter-conf/config.json ; then cp /filter-conf/config.json /uniquefilter/data/filter-config.json ; fi ; /uniquefilter/sbin/nginx "$@" ' > start.sh

RUN useradd -ms /bin/bash firco \
  && usermod -aG root firco

USER firco
# Run nginx
# ----------------------------------------------------------
ENV LD_LIBRARY_PATH=/uniquefilter/modules/

ENTRYPOINT ["bash", "/start.sh" , "-p", "/uniquefilter", "-g", "daemon off;"]