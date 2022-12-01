FROM {{deps.oracle.name}}

ARG TRUST_DATABASE_HOME='/opt/fircosoft/trust/database'

ENV DB_USER='trust'
ENV DB_PWD='hello00'
ENV DB_TS='USERS'

ENV PATH="$ORACLE_HOME/bin:$PATH"

ENV ORACLE_SID='ORCLCDB'
ENV ORACLE_PWD='Fircosoft00'

COPY --chown=oracle:dba shared/startup $ORACLE_BASE/scripts/startup
COPY --chown=oracle:dba shared/setup $TRUST_DATABASE_HOME/setup
COPY --chown=oracle:dba 19c/setup.sh $TRUST_DATABASE_HOME

HEALTHCHECK --interval=5s --timeout=120s --retries=30 \
  CMD /bin/bash -c "[ -f /tmp/status.created ]"

USER root
RUN chown -R oracle:dba $TRUST_DATABASE_HOME
USER oracle

RUN echo "Pulling {{deps.database.uri}}" \
  && curl -s {{deps.database.uri}} \
    | sed -e "s%ACCEPT LOGDIR%DEFINE LOGDIR = . --%" \
    | sed -e "s%ACCEPT TS_DATA%DEFINE TS_DATA = $DB_TS --%" \
    | sed -e "s%ACCEPT TS_INDEX%DEFINE TS_INDEX = $DB_TS --%" \
    > $TRUST_DATABASE_HOME/setup/0002.create.database.as.user.sql \
  && DB_USER=$DB_USER \
     DB_PWD=$DB_PWD \
     DB_TS=$DB_TS \
     ORACLE_SID=$ORACLE_SID \
     ORACLE_PWD=$ORACLE_PWD \
     TRUST_DATABASE_HOME=$TRUST_DATABASE_HOME \
       $TRUST_DATABASE_HOME/setup.sh \
  && head -21 $TRUST_DATABASE_HOME/setup/0002.create.database.as.user.sql \
      > $TRUST_DATABASE_HOME/header \
  && cat $TRUST_DATABASE_HOME/header \
  && rm -rf $TRUST_DATABASE_HOME/setup*
