FROM adoptopenjdk/openjdk11:jre-11.0.11_9-alpine

ENV JDBCPROXY_VERSION={{deps.jdbcproxy.version}}.p{{deps.jdbcproxy.push}}

WORKDIR /fircosoft

ADD {{deps.jdbcproxy.uri}} /fircosoft/

ENTRYPOINT java -jar "/fircosoft/jdbcproxy-$JDBCPROXY_VERSION.jar"