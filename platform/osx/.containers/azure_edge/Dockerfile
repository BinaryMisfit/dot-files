FROM mcr.microsoft.com/azure-sql-edge:latest
USER root
RUN apt-get update
RUN apt-get install python3 python3-pip --yes
RUN python -m pip install mssql-cli
RUN mkdir -p /scripts
RUN mkdir -p /sqldata
COPY *.sh /scripts
RUN chmod -R +x /scripts/*.sh
#RUN chown -R mssql: /sqldata
#RUN chown -R mssql: /var/opt/mssql/data
#USER mssql
ENTRYPOINT /bin/bash /scripts/entrypoint.sh
