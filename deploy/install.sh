#!/usr/bin/env bash
ARGS_DOTBOT="-q"
ARGS_GIT="--quiet"
ARGS_INSTALL=
BASE_DIR="${HOME}/.dotfiles"
CONF_SUFFIX=".conf.yaml"
DEFAULT_CONFIG_PREFIX="default"
DEPLOY_DIR="${BASE_DIR}/deploy"
DOT_BOT_BIN="bin/dotbot"
DOT_BOT_DIR="${BASE_DIR}/dotbot"
FINAL_CONFIG_PREFIX="final"
INSTALL_CONFIG_PREFIX="install"
INSTALL_SCRIPTS="${BASE_DIR}/default/scripts/install/"
OPTIND=1
REMOTE_REPO=https://github.com/BinaryMisfit/dot-files
UPDATE=1
VERBOSE=0

while getopts "Qv" OPT; do
  case "${OPT}" in
    Q)
      UPDATE=0
      ;;
    v)
      VERBOSE=1
      ARGS_DOTBOT="-vv"
      ARGS_GIT=
      ARGS_INSTALL="-v"
      ;;
  esac
done

shift $((OPTIND-1))

[[ "${1:-}" = "--" ]] && shift

OS_PREFIX=
case "${OSTYPE}" in
  "darwin"*)
    OS_PREFIX='osx'
    ;;
  "linux-gnu")
    OS_PREFIX=$(grep </etc/os-release "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
    ;;
  *)
    printf "\033[0;31mUnknown OS: ${OSTYPE}, aborting\n"
    exit 1
    ;;
esac

printf "\033[0;32m==> Found ${OS_PREFIX}\033[0m"

if [[ $(command -v git) == "" ]]; then
  printf "\033[0;31m\ngit not found, aborting\033[0m\n"
  exit 1
fi

if [[ $(command -v add-apt-repository) == "" ]]; then
  printf "\033[0;31m\nadd-add-apt-repository not found, aborting\033[0m\n"
  exit 1
fi

if [[ ! -d "${BASE_DIR}" ]]; then
  if [[ "${VERBOSE}" == "1" ]]; then
    printf "\033[0;34m\nInstalling dotfiles\033[0m"
  fi

  bash -c "unset HOME; git clone --depth 1 --recurse-submodules ${ARGS_GIT} \
    \"${REMOTE_REPO}\" \"${BASE_DIR}\""
fi

if [[ ! -f "${DOT_BOT_DIR}/${DOT_BOT_BIN}" ]]; then
  if [[ "${VERBOSE}" == "1" ]]; then
    printf "\033[0;34m\nUpdating dotbot\033[0m"
  fi

  bash -c "unset HOME; git -C \"${BASE_DIR}\" submodule update --init --recursive --rebase ${ARGS_GIT}"
fi

printf "\033[0;32m\nAll commands have been executed\033[0m"

if [[ "${UPDATE}" == "1" ]]; then
  if [[ "${VERBOSE}" == "1" ]]; then
    printf "\033[0;34m\nUpdating repository\033[0m"
  fi

  bash -c "unset HOME; git -C \"${BASE_DIR}\" pull --autostash --all --recurse-submodules --rebase ${ARGS_GIT}"
  printf "\033[0;32m\nAll files have been updated\033[0m"
fi

printf "\033[0;32m\n\n==> All tasks executed successfully\033[0m"

if [[ -x "${INSTALL_SCRIPTS}${OS_PREFIX}" ]]; then
  printf "\033[0;32m\nApplying install\033[0m"
  bash -c "sudo \"${INSTALL_SCRIPTS}${OS_PREFIX}\" ${ARGS_INSTALL}"
fi

for CONF in ${DEFAULT_CONFIG_PREFIX} ${OS_PREFIX}.${INSTALL_CONFIG_PREFIX} ${OS_PREFIX} ${FINAL_CONFIG_PREFIX} "${@}"; do
  if [[ ! -f "${DEPLOY_DIR}/${CONF}${CONF_SUFFIX}" ]]; then
    continue
  fi

  printf "\033[0;32mApplying ${CONF}\033[0m\n"
  "${DOT_BOT_DIR}/${DOT_BOT_BIN}" -d "${BASE_DIR}" ${ARGS_DOTBOT} \
    -c "${DEPLOY_DIR}/${CONF}${CONF_SUFFIX}"
done

unset ARGS_DOTBOT
unset ARGS_GIT
unset ARGS_INSTALL
unset BASE_DIR
unset CONF_SUFFIX
unset DEFAULT_CONFIG_PREFIX
unset DEPLOY_DIR
unset DOT_BOT_BIN
unset DOT_BOT_DIR
unset DOT_BOT_PLUG
unset FINAL_CONFIG_PREFIX
unset INSTALL_CONFIG_PREFIX
unset OPTIND
unset REMOTE_REPO
unset UPDATE
unset VERBOSE
