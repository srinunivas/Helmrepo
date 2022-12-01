# Pull base image
# ---------------
FROM mcr.microsoft.com/mssql/server:2019-GA-ubuntu-16.04


# Maintainer
# ----------
LABEL maintainer "RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"

# Get main information directly from imageData info
# -------------------------------------------------
LABEL product "{{product}}"
LABEL asset "{{asset}}"
LABEL version "{{deps.sqlmain.version}}"

# Get push information directly from artifact
# -------------------------------------------
LABEL push "{{deps.sqlmain.push}}"

# Copy imageData configuration file
#  and dependencies configuration files in the image itself
# ---------------------------------------------------------
COPY {{imageDataPath}} /imageData


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV SA_PASSWORD=Hello0011
ENV ACCEPT_EULA=Y

# Copy sql file to build continuity db user
# ----------
ADD {{deps.sqlmain.installpath}}/*Creation*.sql /opt/mssql/advancedReporting.sql
ADD ./sql /opt/mssql/
ADD ./scripts /opt/mssql/

# Copy sql file to build continuity db user
# ----------

RUN /opt/mssql/startup/0001_startup.sh ${SA_PASSWORD}

CMD ["/opt/mssql/bin/sqlservr"]