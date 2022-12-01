FROM centos:7
RUN yum install -y libicu
WORKDIR /home
COPY {{deps.erf.installpath}}/SAMDeploy/SafeAlertSuite.{{version}}/netcoreapp3.1 .
RUN chmod +x ./SAMConsole