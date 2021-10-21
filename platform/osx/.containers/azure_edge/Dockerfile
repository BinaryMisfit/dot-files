FROM mcr.microsoft.com/azure-sql-edge:latest
USER root
RUN mkdir -p /scripts
RUN mkdir -p /sqldata
COPY *.sh /scripts
RUN chmod -R +x /scripts/*.sh
RUN chown -R mssql:mssql /sqldata
RUN chown -R mssql:mssql /var/opt/mssql/data
#USER mssql
ENTRYPOINT /bin/bash ./scripts/entrypoint.sh
