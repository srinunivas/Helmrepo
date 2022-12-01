# Pull base image
# ---------------
FROM {{deps.base.name}} as base


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


## Update base
## ----------
USER root
RUN yum update -y
RUN yum install -y \
    sudo 


# Copy reference files to trigger rebuild upon change
# ----------
USER root
COPY {{imageDataPath}} /imageData


# Create fircosoft users
# ----------
RUN groupadd -g 2000 fircosoft && \
    useradd -m -p '' -s /bin/bash -u 2000 -g fircosoft admin && \
    chmod -R 750 /home/admin && \
    useradd -m -p '' -s /bin/bash -u 2001 -g fircosoft continuity && \
    chmod -R 750 /home/continuity && \
    useradd -m -p '' -s /bin/bash -u 2002 -g fircosoft trust && \
    chmod -R 750 /home/trust && \
    useradd -m -p '' -s /bin/bash -u 2003 -g fircosoft filter && \
    chmod -R 750 /home/filter


# Add users to sudoers
# ----------
RUN usermod -aG wheel admin
RUN usermod -aG wheel continuity
RUN usermod -aG wheel trust
RUN usermod -aG wheel filter


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV ADMIN_HOME=/home/admin
ENV CONTINUITY_HOME=/home/continuity
ENV TRUST_HOME=/home/trust
ENV FILTER_HOME=/home/filter
ENV SCRIPTS scripts


# Copy utility scripts
# ----------
USER admin
RUN mkdir -p $ADMIN_HOME/$SCRIPTS
COPY --chown=admin:fircosoft wait-for-it.sh $ADMIN_HOME/$SCRIPTS
RUN chown -R admin:fircosoft $ADMIN_HOME/$SCRIPTS
RUN chmod -R 755 $ADMIN_HOME/$SCRIPTS
USER continuity
RUN ln -s $ADMIN_HOME/$SCRIPTS $CONTINUITY_HOME
USER trust
RUN ln -s $ADMIN_HOME/$SCRIPTS $TRUST_HOME
USER filter
RUN ln -s $ADMIN_HOME/$SCRIPTS $FILTER_HOME


# Add the default port for the filter in continuty config files
# ----------
USER root
RUN echo "fircoof         3005/tcp        #Firco Filter" >> /etc/services


# Start as admin user
# ----------
USER admin
WORKDIR $ADMIN_HOME


# Start container command
# ----------
CMD [ "/bin/bash" ]