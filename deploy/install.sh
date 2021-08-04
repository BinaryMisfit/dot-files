#!/usr/bin/env bash
BASE_DIR="${HOME}/.dotfiles"
CONF_SUFFIX=".conf.yaml"
DEFAULT_CONFIG_PREFIX="default"
DOT_BOT_BIN="bin/dotbot"
FINAL_CONFIG_PREFIX="final"
INSTALL_CONFIG_PREFIX="install"
REMOTE_REPO=https://github.com/BinaryMisfit/dot-files

if [[ "${SUDO_USER}"  != "" ]]; then
  BASE_DIR="/home/${SUDO_USER}/.dotfiles"
fi

if [[ -f "${BASE_DIR}/default/scripts/shared/bmfunc.sh" ]]; then
  source "${BASE_DIR}/default/scripts/shared/bmfunc.sh"
  if [[ ! -z "${BM_LOADED+x}" ]]; then
    bm_init
  else
    printf "\r\033[0;91m[FAILED]\033[0m Shared functions not loaded\033[0m\n"
    exit 255
  fi
else
  printf "\r\033[0;91m[FAILED]\033[0m Shared functions not found\033[0m\n"
  exit 255
fi

BASE_DIR="/home/${BM_USER}/.dotfiles"
DEPLOY_DIR="${BASE_DIR}/deploy"
DOT_BOT_DIR="${BASE_DIR}/dotbot"
INSTALL_SCRIPTS="${BASE_DIR}/default/scripts/install/"

bm_info "${USER}/${SUDO_USER}/${EUID}\n"
bm_title "BinaryMisfit Install Script V1.0.0"
bm_detect_os
bm_locate git
bm_info "Base directory ${BASE_DIR}"
bm_info "Deploy directory ${DEPLOY_DIR}"
bm_info "dotbot directory ${DOT_BOT_DIR}"
bm_info "Script path $0"
bm_info "User ${BM_USER}"
bm_progress "Locating dotfiles"

if [[ ! -d "${BASE_DIR}" ]]; then
  bm_update "Locating dotfiles"
  bm_execute "unset HOME; git clone --depth 1 --recurse-submodules \"${REMOTE_REPO}\" \"${BASE_DIR}\""
  if [[ "$?" != "0" ]]; then
    bm_failed "Locating dotfiles"
    bm_last_error
    bm_error_exit
  fi

  bm_complete "Locating dotfiles"
  bm_last_command
else
  bm_complete "Locating dotfiles"
fi

bm_progress "Locating dotbot"
if [[ ! -f "${DOT_BOT_DIR}/${DOT_BOT_BIN}" ]]; then
  bm_update "Locating dotbot"
  bm_execute "unset HOME; git -C \"${BASE_DIR}\" submodule update --init --recursive --rebase"
  if [[ "$?" != "0" ]]; then
    bm_failed "Locating dotbot"
    bm_last_error
    bm_error_exit
  fi

  bm_complete "Locating dotbot"
  bm_last_command
else
  bm_complete "Locating dotbot"
fi

bm_progress "Updating dotfiles"
if [[ "${BM_SKIP}" == "0" ]]; then
  bm_update "Updating dotfiles"
  MD5_CURRENT="SKIPPED"
  MD5_NEW="SKIPPED"
  MD5_FOUND=$(bm_check md5sum)
  if [[ "${MD5_FOUND}" == "1" ]]; then
    MD5_CURRENT=$(md5sum ${0} | awk '{ print $1 }')
  fi

  VERSION_CURRENT=$(git -C ${BASE_DIR} rev-parse HEAD)
  bm_execute "unset HOME; git -C \"${BASE_DIR}\" pull --autostash --all --recurse-submodules --rebase"
  if [[ "$?" != "0" ]]; then
    bm_failed "Updating dotfiles"
    bm_last_error
    bm_error_exit
  fi

  VERSION_NEW=$(git -C ${BASE_DIR} rev-parse HEAD)
  if [[ "${VERSION_CURRENT}" != "${VERSION_NEW}" ]] || [[ "${MD5_CURRENT}" != "${MD5_NEW}" ]]; then
    bm_reboot "Updating dotfiles"
    bm_last_command
    bm_info "Git Local\t${VERSION_CURRENT}"
    bm_info "Git remote\t${VERSION_NEW}"
    bm_info "Script found\t${MD5_CURRENT}"
    bm_info "Script latest\t${MD5_NEW}"
    echo -ne "\nexec $0 -s ${BM_ARGS/s/}"
  fi

  bm_complete "Updating dotfiles"
  bm_last_command
  bm_info "Git Local\t${VERSION_CURRENT}"
  bm_info "Git remote\t${VERSION_NEW}"
  bm_info "Script found\t${MD5_CURRENT}"
  bm_info "Script latest\t${MD5_NEW}"
  unset MD5_FOUND
  unset MD5_CURRENT
  unset MD5_NEW
  unset VERSION_CURRENT
  unset VERSION_NEW
else
  bm_skip "Updating dotfiles"
fi

bm_progress "Running installion"
if [[ -x "${INSTALL_SCRIPTS}${BM_OS}" ]]; then
  bm_update "Running installation"
  COMMAND="${INSTALL_SCRIPTS}${BM_OS}"
  bm_execute "${COMMAND}"
  if [[ "$?" != "0" ]]; then
    bm_failed "Running installation"
    bm_last_error
    bm_error_exit
  fi

  bm_complete "Running installation"
  bm_last_command
  unset COMMAND
else
  bm_skip "Running installation"
fi

for CONF in ${DEFAULT_CONFIG_PREFIX} ${OS_PREFIX}.${INSTALL_CONFIG_PREFIX} ${OS_PREFIX} ${FINAL_CONFIG_PREFIX} "${@}"; do
  if [[ ! -f "${DEPLOY_DIR}/${CONF}${CONF_SUFFIX}" ]]; then
    continue
  fi

  bm_progress "Running $CONF"
  bm_execute "${DOT_BOT_DIR}/${DOT_BOT_BIN} -d \"${BASE_DIR}\" -c \"${DEPLOY_DIR}/${CONF}${CONF_SUFFIX}\""
  if [[ "$?" != "0" ]]; then
    bm_failed "Running $CONF"
    bm_last_error
    bm_error_exit
  fi

  bm_complete "Running $CONF"
  bm_last_command
done

unset BASE_DIR
unset CONF_SUFFIX
unset DEFAULT_CONFIG_PREFIX
unset DEPLOY_DIR
unset DOT_BOT_BIN
unset DOT_BOT_DIR
unset FINAL_CONFIG_PREFIX
unset INSTALL_CONFIG_PREFIX
unset REMOTE_REPO

if [[ ! -z "${BM_INIT+x}" ]]; then
  bm_deinit
fi
