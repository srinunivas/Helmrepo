FROM {{deps.base.name}}

LABEL maintainer "RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"
LABEL product "continuity6"
LABEL asset "cty-cmapi"
LABEL component "cmapi-soap-server-mock"
LABEL version "master"

RUN apk update && apk upgrade && apk add openjdk11-jre
COPY {{deps.mock.path}} /tmp/mock.zip
RUN mkdir /opt/cty-backend && unzip -d /opt/cty-backend /tmp/mock.zip && rm /tmp/mock.zip
COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
