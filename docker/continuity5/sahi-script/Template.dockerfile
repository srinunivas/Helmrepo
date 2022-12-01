# Pull base image
# ---------------
FROM ubuntu
# The image will create a sahi docker image

# Maintainer
# ----------
LABEL maintainer="Maamoun Soltani <maamoun.soltani@accuity.com>"
# Install third parties
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -qqq update \
 && apt -qq install -y net-tools git default-jre
# Install sahi
RUN mkdir sahi_pro
COPY "{{deps.sahi-engine.path}}" /sahi_pro/sahi-installer.jar
COPY ./conf/silent_install.xml /sahi_pro/
RUN java -jar /sahi_pro/sahi-installer.jar /sahi_pro/silent_install.xml
# Install firefox-esr
RUN apt -qq install -y xdotool software-properties-common \
 && add-apt-repository -y ppa:mozillateam/ppa \
 && apt-get -qq update \
 && apt -qq install -y firefox-esr
# Configure sahi
COPY ./conf/productkey.txt /sahi_pro_911/userdata/config 
COPY ./conf/browser_types.xml /sahi_pro_911/userdata/config 
# Add bitbucket.fircosoft.net known public and private keys
RUN mkdir /root/.ssh/ \
    && chmod +w /root/.ssh/
COPY ./conf/id_rsa /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa \
 && ssh-keyscan -H dev-bitbucket.fircosoft.net >> ~/.ssh/known_hosts
# Run Sahi engine
WORKDIR /sahi_pro_911/userdata/bin/
RUN sed -i 's+=5+=1+g' testrunner.sh 
# Clone Script
RUN git clone --single-branch --branch sahiscript/"{{version}}" ssh://git@dev-bitbucket.fircosoft.net/cty/sahi.git /sahi_pro_911/userdata/scripts/suite
COPY ./conf/wrapper_script.sh /sahi_pro_911/userdata/bin/
RUN chmod +x wrapper_script.sh
CMD ./wrapper_script.sh $CTY_URL