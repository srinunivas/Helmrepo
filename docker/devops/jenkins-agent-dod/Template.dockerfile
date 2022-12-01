FROM adoptopenjdk/openjdk8:jdk8u272-b10-alpine

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG docker_gid=990

RUN addgroup -g ${docker_gid} docker \
  && addgroup -g ${gid} ${group} \
  && adduser -h /home/${user} -u ${uid} -G ${group} -D ${user} \
  && addgroup ${user} docker \
  && mkdir -p -m 775 /usr/share/jenkins

ARG AGENT_WORKDIR=/home/${user}/agent

COPY {{deps.swarm.path}} /usr/share/jenkins/
ENV JENKINS_SWARM_JAR=/usr/share/jenkins/{{deps.swarm.filename}}

RUN apk add --update --no-cache curl bash git git-lfs openssh-client openssl procps docker python3 jq \
  && curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod 775 /usr/local/bin/docker-compose

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins \
  && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins ${AGENT_WORKDIR}
WORKDIR /home/${user}

COPY --chown=${user}:${group} entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
