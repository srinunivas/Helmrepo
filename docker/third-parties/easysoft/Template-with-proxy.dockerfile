FROM {{deps.root.name}}

#
# EasySoft
#
WORKDIR /root
COPY {{deps.easysoft.installpath}} ./

ENV ECHO="/bin/echo" TESTEXISTS="-e" TESTLINK="-L" platform="linux"
USER root

RUN yum install -y yum-utils \
    && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

{{#requireLocale}}
RUN yum -y install expect jq glibc-locale-source glibc-langpack-en docker-ce docker-ce-cli containerd.io haproxy
{{/requireLocale}}
{{^requireLocale}}
RUN yum -y install expect jq docker-ce docker-ce-cli containerd.io haproxy
{{/requireLocale}}

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
RUN systemctl restart haproxy \
  && systemctl enable haproxy

RUN cd /root/{{deps.easysoft.dirname}} \
    && mkdir -p /usr/local/easysoft \
    && ./install_check_tools \
    && ./install_init 'ODBC-ODBC Bridge' \
    && ./install_check_linux "Easysoft ODBC-Oracle Driver" 1 \
    && ./install_check_root "Easysoft ODBC-Oracle Driver" check_root.txt 1 \
    && tar xf all*.tar -C /usr/local/easysoft \
    && echo product: odbc-oracle > /usr/local/easysoft/oracle_install.info \
    && ./uodbc install unixodbc /usr/local/easysoft "Easysoft ODBC-Oracle Driver" ORACLE 1 0 || test $? -eq 1 \
    && ./install_versioned /usr/local/easysoft \
    && ./install_linkpaths "Easysoft ODBC-Oracle Driver" /usr/local/easysoft/lib \
    && ./install_paths /usr/local/easysoft /usr/local/easysoft/lib \
    && echo n | ./install_license "Easysoft ODBC-Oracle Driver" /usr/local/easysoft \
    && echo n | ./install.ORACLE ORACLE "Easysoft ODBC-Oracle Driver" /usr/local/easysoft || test $? -eq 99 \
    && find /usr/local/easysoft -type d -exec chmod 755 {} \; \
    && chown -R root:root /usr/local/easysoft \
    && rm -Rf /root/{{deps.easysoft.dirname}} \
    && chmod a+w /usr/local/easysoft/license/licenses \
    && chmod a+rwx /usr/local/easysoft/license

COPY entrypoint.sh /opt/third-parties/easysoft/entrypoint.sh
COPY license-dialog.exp /opt/third-parties/easysoft/license-dialog.exp

ENV PATH="${PATH}:/usr/local/easysoft/license/:/usr/local/easysoft/bin/" \
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/easysoft/lib/:/usr/local/easysoft/unixODBC/lib/"

ENTRYPOINT ["/opt/third-parties/easysoft/entrypoint.sh"]
