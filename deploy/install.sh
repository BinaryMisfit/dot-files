#!/usr/bin/env bash
set -e
BASE_DIR="${HOME}/.dotfiles"
CONFIG_SUFFIX=".conf.yaml"
DEFAULT_CONFIG_PREFIX="default"
DEPLOY_DIR="${BASE_DIR}/deploy"
DOT_BOT_DIR="${BASE_DIR}/dotbot"
DOT_BOT_BIN="bin/dotbot"
FINAL_CONFIG_PREFIX="final"
INSTALL_CONFIG_PREFIX="install"

OS_PREFIX=
case "${OSTYPE}" in
"darwin"*)
  OS_PREFIX='osx'
  ;;
"linux-gnu")
  OS_PREFIX=$(grep </etc/os-release "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
  ;;
*)
  echo "Unknown OS: ${OSTYPE}"
  exit 1
  ;;
esac

if [ "${1}" == "-vv" ]; then
  echo "Found ${OS_PREFIX}"
fi

if [ ! -f "${DOT_BOT_DIR}/${DOT_BOT_BIN}" ]; then
  if [ "${1}" == "-vv" ]; then
    echo "Updating dotbot"
  fi

  git -C "${DOT_BOT_DIR}" submodule update --init --recursive --quiet
fi

for CONF in ${DEFAULT_CONFIG_PREFIX} ${INSTALL_CONFIG_PREFIX} ${OS_PREFIX} ${FINAL_CONFIG_PREFIX} "${@}"; do
  if [ "${CONF}" == "-vv" ]; then
    continue
  fi

  if [ "${1}" == "-vv" ]; then
    echo "Applying ${CONF}"
    "${DOT_BOT_DIR}/${DOT_BOT_BIN}" -vv -d "${BASE_DIR}" -c "${DEPLOY_DIR}/${CONF}${CONFIG_SUFFIX}"
  else
    "${DOT_BOT_DIR}/${DOT_BOT_BIN}" -d "${BASE_DIR}" -c "${DEPLOY_DIR}/${CONF}${CONFIG_SUFFIX}"
  fi

done
