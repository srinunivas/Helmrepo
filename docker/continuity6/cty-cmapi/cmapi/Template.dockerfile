FROM {{deps.base.name}}

LABEL maintainer "RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"
LABEL product "continuity6"
LABEL asset "cty-cmapi"
LABEL version "master"

RUN apk update && apk upgrade && apk --no-cache add openjdk11-jre curl openssl
COPY {{deps.cmapi.path}} /tmp/cmapi.zip
RUN mkdir /opt/cty-backend && unzip -d /opt/cty-backend /tmp/cmapi.zip && rm /tmp/cmapi.zip
COPY resources/6400-fbe.cf /opt/cty-backend/conf/fbe.cf
COPY scripts/entrypoint.sh /entrypoint.sh
HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 CMD [ "/opt/cty-backend/cmapi-healthcheck" ]
ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "" ]
