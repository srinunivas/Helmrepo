FROM adoptopenjdk/openjdk11:jre-11.0.11_9-alpine

LABEL net.fircosoft.image.name="FMM JavaBatch"
LABEL net.fircosoft.image.maintainer="David Thomé <david.thome@accuity.com>"
LABEL net.fircosoft.image.category="Java"
LABEL net.fircosoft.image.version="{{deps.javabatchfmm.version}}"

WORKDIR /fircosoft

ADD {{deps.javabatchfmm.uri}} /fircosoft/

RUN unzip /fircosoft/FMM_V{{deps.javabatchfmm.version}}.{{deps.javabatchfmm.push}}-JAVA.zip 

ENTRYPOINT [ "java", "-jar", "ListManager-JavaBatch.jar", "-options=ListManager-JavaBatch.cfg"]

