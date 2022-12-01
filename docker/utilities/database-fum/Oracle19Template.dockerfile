FROM {{deps.oracle.name}}

ARG DB_USER=FUM
ARG DB_PWD=hello00
ARG DB_TS=USERS
ARG DATABASE_HOME=/opt/fircosoft/utilities/fum-database

ENV PATH=$ORACLE_HOME/bin:$PATH
ENV IMPORT_FROM_VOLUME=true

ENV ORACLE_SID='ORCLCDB'
ENV ORACLE_PWD='Fircosoft00'

COPY --chown=oracle:dba shared/startup /opt/fircosoft/scripts/startup
COPY --chown=oracle:dba shared/setup $DATABASE_HOME/setup
COPY --chown=oracle:dba 19c/setup.sh $DATABASE_HOME

HEALTHCHECK --interval=5s --timeout=60s --retries=30 \
  CMD /bin/bash -c "[ -f ${DATABASE_HOME}/status.created ]"

USER root
RUN chown -R oracle:dba $DATABASE_HOME
USER oracle

WORKDIR $DATABASE_HOME
COPY {{deps.database.installpath}}/Oracle/*.sql $DATABASE_HOME/script-sql/

RUN DB_USER=$DB_USER \
     DB_PWD=$DB_PWD \
     DB_TS=$DB_TS \
     ORACLE_SID=$ORACLE_SID \
     ORACLE_PWD=$ORACLE_PWD \
     DATABASE_HOME=$DATABASE_HOME \
     $DATABASE_HOME/setup.sh 
