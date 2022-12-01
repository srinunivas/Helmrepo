FROM {{deps.oracle.name}}

ARG DB_USER=FMM
ARG DB_PWD=hello00
ARG DB_TS=USERS
ARG DATABASE_HOME=/opt/fircosoft/utilities/fum-database

ENV PATH=$ORACLE_HOME/bin:$PATH
ENV IMPORT_FROM_VOLUME=true

WORKDIR $DATABASE_HOME

COPY setup.sh .
COPY setup/ ./setup
COPY touch-status-ready.sh /docker-entrypoint-initdb.d/9999999.touch-status-ready.sh
COPY {{deps.database.installpath}}/Oracle/*.sql ./script-sql/

RUN chown -R oracle:dba /u01/app/oracle . \
  && chmod +x setup.sh \
  && chmod +x /docker-entrypoint-initdb.d/9999999.touch-status-ready.sh \
  && DB_USER=$DB_USER DB_PWD=$DB_PWD DB_TS=$DB_TS ./setup.sh

HEALTHCHECK --interval=5s --timeout=60s --retries=30 \
  CMD /bin/bash -c "[ -f ${DATABASE_HOME}/status.created ]"
