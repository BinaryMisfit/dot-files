#/usr/bin/env sh
LE_DOMAIN=${Le_Domain}
LE_WORK_DIR=${LE_WORKING_DIR}
DOMAIN_DIR="${LE_WORK_DIR}/${LE_DOMAIN}"
SERVICE_NAME=$(echo ${LE_DOMAIN} | cut -d"." -f1)
SERVICE_DIR="/Users/Shared/config/${SERVICE_NAME}"
if [ -d "${SERVICE_DIR}/ssl" ]; then
  ${LE_WORK_DIR}/acme.sh --toPkcs -d ${LE_DOMAIN} --password ${SERVICE_NAME} > /dev/null
  cp "${DOMAIN_DIR}/${LE_DOMAIN}.key" "${SERVICE_DIR}/ssl"
  cp "${DOMAIN_DIR}/${LE_DOMAIN}.pfx" "${SERVICE_DIR}/ssl/${LE_DOMAIN}"
fi

USER_ID=$(id -u)
launchctl kickstart -k gui/${USER_ID}/com.services.haproxy
if [[ -f "${SERVICE_DIR}/ssl_install.sh" ]]; then
  source "${SERVICE_DIR}/ssl_install.sh" 
fi
