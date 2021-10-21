FROM mcr.microsoft.com/azure-sql-edge:latest
USER root
RUN mkdir -p /home/scripts
RUN chmod -R +ox /home/scripts/*.sh
COPY *.sh /scripts
ENTRYPOINT sh -c "/home/scripts/entrypoint.sh"
