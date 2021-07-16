#!/usr/bin/env bash
LE_DOMAIN=${Le_Domain}
LE_WORK_DIR=${LE_WORKING_DIR}
DOMAIN_DIR="${LE_WORK_DIR}/${LE_DOMAIN}"
SERVICE_NAME=$(echo ${LE_DOMAIN} | cut -d"." -f1)
printf "$LE_DOMAIN"
printf "$LE_WORK_DIR"
printf "$DOMAIN_DIR"
printf "$SERVICE_NAME"
