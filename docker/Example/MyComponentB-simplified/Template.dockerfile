FROM httpd:2.4

LABEL org.label-schema.schema-version="1.0" org.label-schema.vendor="Fircosoft" org.label-schema.name="Fircosoft {{product}}/{{asset}}" org.label-schema.vendor="Fircosoft" org.label-schema.build-date="{{buildTimestamp}}" org.label-schema.version="{{version}}"
LABEL maintainer="DevOps <devops@accuity.com>"
# Get main information directly from imageData info
# -------------------------------------------------
LABEL product="{{product}}"
LABEL asset="{{asset}}"
LABEL version="{{version}}"

# Get push information directly from artifact
# -------------------------------------------
LABEL push="{{deps.main.push}}"

# Copy imageData configuration file
#  and dependencies configuration files in the image itself
# ---------------------------------------------------------
COPY {{imageDataPath}} /imageData
RUN ln -s /imageData /usr/local/apache2/htdocs/
COPY run_tests.sh /

# Get package content as automatically extracted by shadoker
#  (because of "extract": true in imageData)
# ----------------------------------------------------------
COPY {{deps.main.installpath}}/*.html /usr/local/apache2/htdocs/