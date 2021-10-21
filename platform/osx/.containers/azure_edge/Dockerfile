FROM mcr.microsoft.com/azure-sql-edge:latest
RUN mkdir -p /scripts
COPY *.sh /scripts
ENTRYPOINT sh -c "/scripts/entrypoint.sh"
