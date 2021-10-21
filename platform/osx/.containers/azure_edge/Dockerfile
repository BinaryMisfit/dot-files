FROM mcr.microsoft.com/azure-sql-edge:latest
USER root
RUN mkdir -p /scripts
COPY *.sh /scripts
RUN chmod -R o+x /scripts/*.sh
ENTRYPOINT sh -c "/scripts/entrypoint.sh"
