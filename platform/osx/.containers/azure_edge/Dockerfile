FROM mcr.microsoft.com/azure-sql-edge:latest
USER root
RUN mkdir -p /scripts
RUN chmod -R o+x /scripts/*.sh
COPY *.sh /scripts
ENTRYPOINT sh -c "/scripts/entrypoint.sh"
