#!/usr/bin/env bash
OPTIND=1
REMOTE_REPO=https://github.com/BinaryMisfit/dot-files
BASE_DIR="${HOME}/.dotfiles"
CONFIG_SUFFIX=".conf.yaml"
DEFAULT_CONFIG_PREFIX="default"
DEPLOY_DIR="${BASE_DIR}/deploy"
DOT_BOT_DIR="${BASE_DIR}/dotbot"
DOT_BOT_BIN="bin/dotbot"
DOT_BOT_PLUG="external/dotplugins"
FINAL_CONFIG_PREFIX="final"
INSTALL_CONFIG_PREFIX="install"
VERBOSE=0
UPDATE=1

while getopts "Qv" OPT; do
  case "${OPT}" in
    Q)
      UPDATE=0
      ;;
    v)
      VERBOSE=1
      ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] &&  shift

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

if [ "${VERBOSE}" == "1" ]; then
  echo "Found ${OS_PREFIX}"
fi

if [ ! -d "${BASE_DIR}" ]; then
  if [ "${VERBOSE}" == "1" ]; then
    echo "Installing dotfiles"
  fi

  if [ "${VERBOSE}" == "1" ]; then
   bash -c "unset HOME; git clone --depth 1 --recurse-submodules \
    \"${REMOTE_REPO}\" \"${BASE_DIR}\""
  else
    bash -c "unset HOME; git clone --depth 1 --recurse-submodules --quiet \
      \"${REMOTE_REPO}\" \"${BASE_DIR}\""
  fi
fi

if [ ! -f "${DOT_BOT_DIR}/${DOT_BOT_BIN}" ]; then
  if [ "${VERBOSE}" == "1" ]; then
    echo "Updating dotbot"
  fi

  if [ "${VERBOSE}" == "1" ]; then
    bash -c "unset HOME; git -C \"${BASE_DIR}\" submodule update --init --recursive"
  else
    bash -c "unset HOME; git -C \"${BASE_DIR}\" submodule update --init --recursive --quiet"
  fi
fi

if [ "${UPDATE}" == "1" ]; then
  if [ "${VERBOSE}" == "1" ]; then
    echo "Updating repository"
  fi

  if [ "${VERBOSE}" == "1" ]; then
    bash -c "unset HOME; git -C \"${BASE_DIR}\" pull --autostash --all --recurse-submodules"
  else
    bash -c "unset HOME; git -C \"${BASE_DIR}\" pull --autostash --all --recurse-submodules --quiet"
  fi
fi

for CONF in ${DEFAULT_CONFIG_PREFIX} ${OS_PREFIX}.${INSTALL_CONFIG_PREFIX} ${OS_PREFIX} ${FINAL_CONFIG_PREFIX} "${@}"; do
  if [ "${CONF}" == "-vv" ]; then
    continue
  fi

  if [ "${VERBOSE}" == "1" ]; then
    echo "Applying ${CONF}"
    "${DOT_BOT_DIR}/${DOT_BOT_BIN}" -vv -d "${BASE_DIR}" \
      -c "${DEPLOY_DIR}/${CONF}${CONFIG_SUFFIX}" --plugin-dir "${BASE_DIR}/${DOT_BOT_PLUG}"
  else
    "${DOT_BOT_DIR}/${DOT_BOT_BIN}" -q -d "${BASE_DIR}" \
      -c "${DEPLOY_DIR}/${CONF}${CONFIG_SUFFIX}" --plugin-dir "${BASE_DIR}/${DOT_BOT_PLUG}"
  fi
done
