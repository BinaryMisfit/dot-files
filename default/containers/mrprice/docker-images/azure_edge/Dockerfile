FROM mcr.microsoft.com/azure-sql-edge:latest
USER root
RUN apt-get update
RUN apt-get upgrade --yes
RUN apt-get install mssql-cli --yes
RUN mkdir -p /scripts
RUN mkdir -p /sqldata
RUN mkdir -p /var/opt/mssql/data
COPY *.sh /scripts
RUN chmod -R +x /scripts/*.sh
#USER mssql
#ENTRYPOINT /bin/bash /scripts/entrypoint.sh
