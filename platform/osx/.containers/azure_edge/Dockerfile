FROM mcr.microsoft.com/azure-sql-edge:latest
RUN sudo mkdir -p /scripts
RUN sudo chmod -R +ox /scripts/*.sh
COPY *.sh /scripts
ENTRYPOINT sh -c "/scripts/entrypoint.sh"
