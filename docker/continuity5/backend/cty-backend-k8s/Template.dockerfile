FROM centos:7

RUN yum install -y glibc.i686 libstdc++.i686 && \
    yum install -y openssl-devel.i686 && \
    yum clean all

COPY {{deps.init.path}} /usr/bin/dumb-init
RUN chmod 755 /usr/bin/dumb-init

RUN mkdir -p /fircosoft

COPY {{deps.coreengine.installpath}} /fircosoft/
COPY {{deps.upgrade-dbclient.installpath}} /fircosoft/
COPY {{deps.upgrade-requester.installpath}} /fircosoft/
COPY {{deps.upgrade-multiplexer.installpath}} /fircosoft/
COPY {{deps.upgrade-pairing.installpath}} /fircosoft/
COPY {{deps.upgrade-stripping.installpath}} /fircosoft/
COPY {{deps.upgrade-advancedreporting.installpath}} /fircosoft/
COPY {{deps.upgrade-dbtools.installpath}} /fircosoft/
COPY {{deps.upgrade-drchecksummigrator.installpath}} /fircosoft/
COPY {{deps.upgrade-predictionintegrator.installpath}} /fircosoft/
COPY {{deps.upgrade-fircocontractmapper.installpath}} /fircosoft/
COPY {{deps.upgrade-jsonutilities.installpath}} /fircosoft/
COPY {{deps.upgrade-mappingcasemanagerapi.installpath}} /fircosoft/
COPY {{deps.upgrade-mappinghttpstatus.installpath}} /fircosoft/
COPY {{deps.upgrade-mappingxmluniversal.installpath}} /fircosoft/
COPY {{deps.upgrade-archiving.installpath}} /fircosoft/

ENV CONTINUITY_PRODUCT={{version}}
ENV COREENGINE_VERSION={{deps.coreengine.env}}-{{deps.coreengine.version}}.p{{deps.coreengine.push}}
ENV DBCLIENT_VERSION={{deps.upgrade-dbclient.env}}-{{deps.upgrade-dbclient.version}}.p{{deps.upgrade-dbclient.push}}
ENV REQUESTER_VERSION={{deps.upgrade-requester.env}}-{{deps.upgrade-requester.version}}.p{{deps.upgrade-requester.push}}
ENV MULTIPLEXER_VERSION={{deps.upgrade-multiplexer.env}}-{{deps.upgrade-multiplexer.version}}.p{{deps.upgrade-multiplexer.push}}
ENV PAIRING_VERSION={{deps.upgrade-pairing.env}}-{{deps.upgrade-pairing.version}}.p{{deps.upgrade-pairing.push}}
ENV STRIPPING_VERSION={{deps.upgrade-stripping.env}}-{{deps.upgrade-stripping.version}}.p{{deps.upgrade-stripping.push}}
ENV ADVANCEDREPORTING_VERSION={{deps.upgrade-advancedreporting.env}}-{{deps.upgrade-advancedreporting.version}}.p{{deps.upgrade-advancedreporting.push}}
ENV DBTOOLS_VERSION={{deps.upgrade-dbtools.env}}-{{deps.upgrade-dbtools.version}}.p{{deps.upgrade-dbtools.push}}
ENV DRCHECKSUMMIGRATOR_VERSION={{deps.upgrade-drchecksummigrator.env}}-{{deps.upgrade-drchecksummigrator.version}}.p{{deps.upgrade-drchecksummigrator.push}}
ENV PREDICTIONINTEGRATOR_VERSION={{deps.upgrade-predictionintegrator.env}}-{{deps.upgrade-predictionintegrator.version}}.p{{deps.upgrade-predictionintegrator.push}}
ENV FIRCOCONTRACTMAPPER_VERSION={{deps.upgrade-fircocontractmapper.env}}-{{deps.upgrade-fircocontractmapper.version}}.p{{deps.upgrade-fircocontractmapper.push}}
ENV JSONUTILITIES_VERSION={{deps.upgrade-jsonutilities.env}}-{{deps.upgrade-jsonutilities.version}}.p{{deps.upgrade-jsonutilities.push}}
ENV MAPPINGCASEMANAGERAPI_VERSION={{deps.upgrade-mappingcasemanagerapi.env}}-{{deps.upgrade-mappingcasemanagerapi.version}}
ENV MAPPINGHTTPSTATUS_VERSION={{deps.upgrade-mappinghttpstatus.env}}-{{deps.upgrade-mappinghttpstatus.version}}.p{{deps.upgrade-mappinghttpstatus.push}}
ENV MAPPINGXMLUNIVERSAL_VERSION={{deps.upgrade-mappingxmluniversal.env}}-{{deps.upgrade-mappingxmluniversal.version}}.p{{deps.upgrade-mappingxmluniversal.push}}
ENV ARCHIVING_VERSION={{deps.upgrade-archiving.env}}-{{deps.upgrade-archiving.version}}.p{{deps.upgrade-archiving.push}}

WORKDIR /fircosoft

RUN mkdir /fircosoft/tmp
RUN mkdir /fircosoft/www
ENV FKRUN_LICENSE_PATH=/fircosoft/shared/fbe.cf

ENTRYPOINT [ "/usr/bin/dumb-init", "./bin32/linux/FKRUN" ]
