#!/usr/bin/env bash
BASE_DIR="${HOME}/.dotfiles"
CONF_SUFFIX=".conf.yaml"
DEFAULT_CONFIG_PREFIX="default"
DOT_BOT_BIN="bin/dotbot"
FINAL_CONFIG_PREFIX="final"
REMOTE_REPO=https://github.com/BinaryMisfit/dot-files

if [[ -f "${BASE_DIR}/default/scripts/shared/bmfunc.sh" ]]; then
  source "${BASE_DIR}/default/scripts/shared/bmfunc.sh"
  if [[ -n "${BM_LOADED+x}" ]]; then
    bm_init
  else
    printf "\r\033[0;91m[FAILED]\033[0;90m Shared functions not loaded\033[0m\n"
    exit 255
  fi
else
  printf "\r\033[0;91m[FAILED]\033[0;90m Shared functions not found\033[0m\n"
  exit 255
fi

bm_print_title "Dotfiles installer V1.0.0"
bm_user_no_sudo
bm_detect_os
bm_command_locate git
bm_command_locate md5sum
bm_print_info "User: ${BM_USER}"
bm_print_info "Home: ${HOME}"
bm_print_info "Sudo: ${BM_USE_SUDO}"

DEPLOY_DIR="${BASE_DIR}/deploy"
DOT_BOT_DIR="${BASE_DIR}/dotbot"
INSTALL_SCRIPTS="${BASE_DIR}/default/scripts/install/"

bm_print_info "Base directory: ${BASE_DIR}"
bm_print_info "Deploy directory: ${DEPLOY_DIR}"
bm_print_info "dotbot directory: ${DOT_BOT_DIR}"
bm_print_info "Script path: $0"
bm_task_start "Locating dotfiles"

if [[ ! -d "${BASE_DIR}" ]]; then
  bm_task_update "Locating dotfiles"
  if ! bm_command_execute "git clone --depth 1 --recurse-submodules ${REMOTE_REPO} ${BASE_DIR}"; then
    bm_task_failed "Locating dotfiles"
    bm_command_output_error
    bm_script_error
  fi

  bm_task_ok "Locating dotfiles"
  bm_command_output_success
else
  bm_task_ok "Locating dotfiles"
fi

bm_task_start "Locating dotbot"
if [[ -f "${DOT_BOT_DIR}/${DOT_BOT_BIN}" ]]; then
  bm_task_update "Locating dotbot"
  if ! bm_command_execute "git -C \"${BASE_DIR}\" submodule update --init --recursive --rebase"; then
    bm_task_failed "Locating dotbot"
    bm_command_output_error
    bm_script_error
  fi

  bm_task_ok "Locating dotbot"
  bm_command_output_success
else
  bm_task_ok "Locating dotbot"
fi

bm_task_start "Updating dotfiles"
if [[ "${BM_SKIP}" == "0" ]]; then
  bm_task_update "Updating dotfiles"
  MD5_CURRENT=$(md5sum "$0" | awk '{ print $1 }')
  VERSION_CURRENT=$(git -C "${BASE_DIR}" rev-parse HEAD)
  if ! bm_command_execute "git -C \"${BASE_DIR}\" pull --autostash --all --recurse-submodules --rebase"; then
    bm_task_failed "Updating dotfiles"
    bm_command_output_error
    bm_script_error
  fi

  MD5_NEW=$(md5sum "$0" | awk '{ print $1 }')
  VERSION_NEW=$(git -C "${BASE_DIR}" rev-parse HEAD)
  if [[ "${VERSION_CURRENT}" != "${VERSION_NEW}" ]] || [[ "${MD5_CURRENT}" != "${MD5_NEW}" ]]; then
    bm_task_reboot "Updating dotfiles"
    bm_command_output_success
    bm_print_info "Git F: ${VERSION_CURRENT}"
    bm_print_info "Git L: ${VERSION_NEW}"
    bm_print_info "Script F: ${MD5_CURRENT}"
    bm_print_info "Script L: ${MD5_NEW}"
  fi

  bm_task_ok "Updating dotfiles"
  bm_command_output_success
  bm_print_info "Git F: ${VERSION_CURRENT}"
  bm_print_info "Git L: ${VERSION_NEW}"
  bm_print_info "Script F: ${MD5_CURRENT}"
  bm_print_info "Script L: ${MD5_NEW}"
  unset MD5_CURRENT
  unset MD5_NEW
  unset VERSION_CURRENT
  unset VERSION_NEW
else
  bm_task_skip "Updating dotfiles"
fi

#bm_task_start "Running installation"
#if [[ -x "${INSTALL_SCRIPTS}${BM_OS}" ]]; then
#  bm_task_update "Running installation"
#  COMMAND="${INSTALL_SCRIPTS}${BM_OS} ${BM_ARGS}"
#  if ! bm_script_execute "${COMMAND}"; then
#    bm_task_failed "Running installation"
#    bm_script_output_raw
#    bm_script_error
#  fi
#
#  bm_task_ok "Running installation"
#  bm_script_output_raw
#  unset COMMAND
#else
#  bm_task_skip "Running installation"
#fi

for CONF in ${DEFAULT_CONFIG_PREFIX} ${BM_OS} ${FINAL_CONFIG_PREFIX} "${@}"; do
  if [[ ! -f "${DEPLOY_DIR}/${CONF}${CONF_SUFFIX}" ]]; then
    bm_print_info "Missing ${CONF}${CONF_SUFFIX}"
    continue
  fi

  bm_task_start "Running config $CONF"
  if ! bm_command_execute "${DOT_BOT_DIR}/${DOT_BOT_BIN} -d \"${BASE_DIR}\" -c \"${DEPLOY_DIR}/${CONF}${CONF_SUFFIX}\""; then
    bm_task_failed "Running config $CONF"
    bm_command_output_error
    bm_script_error
  fi

  bm_task_ok "Running config $CONF"
  bm_command_output_success
done

unset BASE_DIR
unset CONF_SUFFIX
unset DEFAULT_CONFIG_PREFIX
unset DEPLOY_DIR
unset DOT_BOT_BIN
unset DOT_BOT_DIR
unset FINAL_CONFIG_PREFIX
unset REMOTE_REPO

if [[ -n "${BM_INIT+x}" ]]; then
  bm_de_init
fi