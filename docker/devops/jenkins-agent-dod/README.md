The **jenkins-deploy.fircosoft.net/devops/jenkins-agent-dod** image runs a **jenkins swarm agent** and also provides **Docker-on-Docker** and **docker-compose** capability.

## Running command

```bash
chmod a+rw /var/run/docker.sock

docker run \
  --init -d \
  --restart=always \
  --name "jenkins-agent" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$HOME/.ssh":/home/jenkins/.ssh:ro \
  -v "$HOME/.docker/config.json":/home/jenkins/.docker/config.json:ro \
  -v "$PWD/workspace":/home/jenkins/agent:rw \
  jenkins-deploy.fircosoft.net/devops/jenkins-agent-dod:1.0 \
  -master   "$JENKINS_URL"            \
  -username "$JENKINS_USER"           \
  -password "$JENKINS_PASSWORD"       \
  -labels   "$JENKINS_LABELS"         \
  -name     "$JENKINS_NAME"
```