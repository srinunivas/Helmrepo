FROM amazoncorretto:11.0.8-alpine

LABEL maintainer "RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"
LABEL product    "{{product}}"
LABEL asset      "{{asset}}"
LABEL version    "{{version}}"

RUN apk add --no-cache --update bash

ENV WORKDIR_PATH=/usr/local/migration-tools

RUN mkdir ${WORKDIR_PATH}

COPY {{deps.migration-tools.installpath}}/ContinuityMigrationTools ${WORKDIR_PATH}/ContinuityMigrationTools

COPY docker-entrypoint.sh ${WORKDIR_PATH}/ContinuityMigrationTools

RUN chmod +x -R ${WORKDIR_PATH}/ContinuityMigrationTools && \
    mkdir -p ${WORKDIR_PATH}/conf                        && \
    mkdir -p ${WORKDIR_PATH}/log                         && \
    mkdir -p ${WORKDIR_PATH}/tmp

WORKDIR ${WORKDIR_PATH}/ContinuityMigrationTools

ENTRYPOINT ["./docker-entrypoint.sh"]
