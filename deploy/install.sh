#!/usr/bin/env bash
set -e
DEFAULT_CONFIG_PREFIX="default"
INSTALL_CONFIG_PREFIX="install"
FINAL_CONFIG_PREFIX="final"
CONFIG_SUFFIX=".conf.yaml"
DOT_BOT_DIR="dotbot"
DOT_BOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

cd "${BASEDIR}"
git -C "${DOT_BOT_DIR}" submodule sync --quiet --recursive
git submodule update --init --recursive "${DOT_BOT_DIR}"
for conf in ${DEFAULT_CONFIG_PREFIX} ${INSTALL_CONFIG_PREFIX} ${OS_PREFIX} ${FINAL_CONFIG_PREFIX} "${@}"; do
  "${BASEDIR}/${DOT_BOT_DIR}/${DOT_BOT_BIN}" -d "${BASEDIR}" -c "${conf}${CONFIG_SUFFIX}"
done