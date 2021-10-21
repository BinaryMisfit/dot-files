FROM mcr.microsoft.com/azure-sql-edge:latest
USER root
RUN mkdir -p /scripts
RUN which sh
RUN which bash
COPY *.sh /scripts
RUN chmod -R o+x /scripts/*.sh
ENTRYPOINT /bin/bash ./scripts/entrypoint.sh
