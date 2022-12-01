# Pull base image
# ---------------
ARG ORACLELINUX_BASE_IMAGE
FROM $ORACLELINUX_BASE_IMAGE as base


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


## Update base
## ----------
RUN yum update -y
RUN yum install -y \
    python3 \
    sudo 


# Arguments that need to be set outside dockerfle before building
# Variables not available on container
# ----------
ARG IMAGE_DATA_FILE

RUN echo IMAGE_DATA_FILE=$IMAGE_DATA_FILE


## Build python3.7 -- pyodbc failed with python3 package on oracle linux
## ----------
RUN yum -y install wget \
    && yum -y install gcc readline readline-devel \
    && yum -y install zlib zlib-devel \
    && yum -y install libffi-devel openssl-devel \
    && yum -y install tar gzip \
    && yum -y install make \
    && yum clean all

RUN  wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tgz \
     && tar -xf Python-3.7.5.tgz \
     && cd Python-3.7.5 \
     && ./configure --enable-optimizations \
     && make \
     && make install

RUN rm -rf Python-3.7.5.tgz Python-3.7.5


# Install pip, pytest, jinja, cx_Oracle and pyodbc. Note that pyodbc requires gcc-c++ and unixODBC-devel
## ----------
RUN yum install -y gcc-c++ unixODBC-devel
RUN alternatives --install /usr/bin/python python /usr/bin/python2         275
RUN alternatives --install /usr/bin/python python /usr/bin/python3         368
RUN alternatives --install /usr/bin/python python /usr/local/bin/python3.7 370
RUN alternatives --auto python
RUN yes | python -m pip install --upgrade pip
RUN yes | python -m pip install --upgrade pytest 
RUN yes | python -m pip install --upgrade jinja2 
RUN yes | python -m pip install --upgrade cx_Oracle 
RUN yes | python -m pip install --upgrade pyodbc 


# Copy reference files to trigger rebuild upon change
# ----------
USER root
RUN mkdir -p /imageData/images
RUN mkdir -p /imageData/artifacts
COPY $IMAGE_DATA_FILE          /imageData/imageData.json
COPY ./imageData/images/       /imageData/images/
COPY ./imageData/artifacts/    /imageData/artifacts/


# Uses python2 by default
# Needed for yum
# ----------
RUN alternatives --set python /usr/bin/python2


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