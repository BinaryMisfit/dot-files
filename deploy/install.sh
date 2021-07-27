#!/usr/bin/env bash
ARGS_ALL=${@}
ARGS_INSTALL=
BASE_DIR="${HOME}/.dotfiles"
COMMAND=
CONF_SUFFIX=".conf.yaml"
DEFAULT_CONFIG_PREFIX="default"
DEPLOY_DIR="${BASE_DIR}/deploy"
DOT_BOT_BIN="bin/dotbot"
DOT_BOT_DIR="${BASE_DIR}/dotbot"
FINAL_CONFIG_PREFIX="final"
FORCE=0
INSTALL_CONFIG_PREFIX="install"
INSTALL_SCRIPTS="${BASE_DIR}/default/scripts/install/"
MD5_CURRENT=$(md5sum ${0} | awk '{ print $1 }')
MD5_NEW=
OPTIND=1
OUTPUT=
REMOTE_REPO=https://github.com/BinaryMisfit/dot-files
UPDATE=1
VERBOSE=0
VERSION_CURRENT=
VERSION_NEW=

while getopts "fQsv" OPT; do
  case "${OPT}" in
    f)
      ARGS_INSTALL="-f"
      FORCE=1
      UPDATE=0
      VERBOSE=1
      ;;
    Q)
      UPDATE=0
      ;;
    s)
      ARGS_INSTALL="-s"
      VERBOSE=-1
      ;;
    v)
      ARGS_INSTALL="-v"
      VERBOSE=1
      ;;
  esac
done

shift $((OPTIND-1))

[[ "${1:-}" = "--" ]] && shift

if [[ "${SUDO_USER}"  != "" ]]; then
  BASE_DIR="/home/${SUDO_USER}/.dotfiles"
  DEPLOY_DIR="${BASE_DIR}/deploy"
  DOT_BOT_DIR="${BASE_DIR}/dotbot"
  INSTALL_SCRIPTS="${BASE_DIR}/default/scripts/install/"
fi

if [[ "${VERBOSE}" == "1" ]]; then
  printf "\033[0;94m[ INFO ] Arguments ${ARGS_ALL}\033[0m"
  printf "\n\033[0;94m[ INFO ] Install arguments ${ARGS_INSTALL}\033[0m"
  printf "\n\033[0;94m[ INFO ] User ${USER}\033[0m"
  printf "\n\033[0;94m[ INFO ] SUDO user ${SUDO_USER}\033[0m"
  printf "\n\033[0;94m[ INFO ] Base directory ${BASE_DIR}\033[0m"
  printf "\n\033[0;94m[ INFO ] Deploy directory ${DEPLOY_DIR}\033[0m"
  printf "\n\033[0;94m[ INFO ] dotbot directory ${DOT_BOT_DIR}\033[0m"
  printf "\n\033[0;94m[ INFO ] Script path ${0}\033[0m\n"
fi

if [[ "${VERBOSE}" != "-1" ]]; then
  printf "\033[0;92m[  ..  ]\033[0m OS detection\033[0m"
fi

OS_PREFIX=
case "${OSTYPE}" in
  "darwin"*)
    OS_PREFIX='osx'
    ;;
  "linux-gnu")
    OS_PREFIX=$(grep </etc/os-release "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
    ;;
  "linux-gnueabihf")
    OS_PREFIX=$(grep </etc/os-release "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
    ;;
  *)
    printf "\r\033[0;91m[FAILED]\033[0m OS detected ${OSTYPE}\033[0m"
    printf "\n"
    exit 1
    ;;
esac

if [[ "${VERBOSE}" != "-1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m OS detected ${OS_PREFIX}\033[0m"
  printf "\n\033[0;92m[  ..  ]\033[0m Locating git\033[0m"
fi

if [[ $(command -v git) == "" ]]; then
  printf "\r\033[0;91m[FAILED]\033[0m Locating git\033[0m"
  printf "\n"
  exit 1
fi

if [[ "${VERBOSE}" != "-1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Locating git\033[0m"
  printf "\n\033[0;92m[  ..  ]\033[0m Locating dotfiles\033[0m"
fi

if [[ ! -d "${BASE_DIR}" ]]; then
  if [[ "${VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;93m[UPDATE]\033[0m Locating dotfiles\033[0m"
  fi

  COMMAND="unset HOME; git clone --depth 1 --recurse-submodules \"${REMOTE_REPO}\" \"${BASE_DIR}\""
  OUTPUT=$(bash -c "${COMMAND}" 2>&1)
  readarray -t OUTPUT <<< "${OUTPUT}"
  if [[ "${?}" != "0" ]]; then
    printf "\r\033[0;91m[FAILED]\033[0m Locating dotfiles\033[0m"
    if [[ "${VERBOSE}" == "1" ]]; then
      printf "\n\033[0;94m[SCRIPT] ${COMMAND}\033[0m"
      if [[ "${OUTPUT}" != "" ]]; then
        printf "\n\033[0;94m[OUTPUT] %s\033[0m" "${OUTPUT[@]}"
      fi
    fi

    printf "\n"
    exit 1
  fi
fi

if [[ "${VERBOSE}" != "-1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Locating dotfiles\033[0m"
  if [[ "${VERBOSE}" == "1" ]] && [[ "${COMMAND}" != "" ]]; then
    printf "\n\033[0;93m[SCRIPT]\033[0m ${COMMAND}\033[0m"
    if [[ "${OUTPUT}" != "" ]]; then
      printf "\033[0;94m[OUTPUT]\033[0m %s\n\033[0m" "${OUTPUT[@]}"
    fi
  fi

  printf "\n\033[0;92m[  ..  ]\033[0m Locating dotbot\033[0m"
fi

if [[ ! -f "${DOT_BOT_DIR}/${DOT_BOT_BIN}" ]]; then
  printf "\033[0;93m\r[UPDATE]\033[0m Locating dotbot\033[0m"
  COMMAND="unset HOME; git -C \"${BASE_DIR}\" submodule update --init --recursive --rebase"
  OUTPUT=$(bash -c "${COMMAND}" 2>&1)
  readarray -t OUTPUT <<< "${OUTPUT}"
  if [[ "${?}" != "0" ]]; then
    printf "\r\033[0;91m[FAILED]\033[0m Locating dotbot\033[0m"
    if [[ "${VERBOSE}" == "1" ]]; then
      if [[ "${COMMAND}" != "" ]]; then
        printf "\n\033[0;94m[SCRIPT] ${COMMAND}\033[0m"
      fi

      if [[ "${OUTPUT}" != "" ]]; then
        printf "\n\033[0;94m[OUTPUT] %s\033[0m" "${OUTPUT[@]}"
      fi
    fi

    printf "\n"
    exit 1
  fi
fi

if [[ "${VERBOSE}" != "-1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Locating dotbot\033[0m"
  if [[ "${VERBOSE}" == "1" ]]; then
    if [[ "${COMMAND}" != "" ]]; then
      printf "\n\033[0;94m[SCRIPT] ${COMMAND}\033[0m"
    fi

    if [[ "${OUTPUT}" != "" ]]; then
      printf "\n\033[0;94m[OUTPUT] %s\033[0m" "${OUTPUT[@]}"
    fi

    printf "\n\033[0;94m[ INFO ] Update parameter set ${UPDATE}\033[0m"
  fi

  printf "\n\033[0;92m[  ..  ]\033[0m Updating repository\033[0m"
fi

VERSION_CURRENT=$(git -C ${BASE_DIR} rev-parse HEAD)
if [[ "${UPDATE}" == "1" ]]; then
  if [[ "${VERBOSE}" != "-1" ]]; then
    printf "\033[0;93m\r[UPDATE]\033[0m Updating repository\033[0m"
  fi

  COMMAND="unset HOME; git -C \"${BASE_DIR}\" pull --autostash --all --recurse-submodules --rebase"
  OUTPUT=$(bash -c "${COMMAND}" 2>&1)
  readarray -t OUTPUT <<< "${OUTPUT}"
  VERSION_NEW=$(git -C ${BASE_DIR} rev-parse HEAD)
  MD5_NEW=$(md5sum ${0} | awk '{ print $1 }')
  if [[ "${SUDO_USER}" != "" ]]; then
    sudo chown -R "${SUDO_USER}":"${SUDO_USER}" "${BASE_DIR}"
  fi

  if [[ "${VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;92m[  OK  ]\033[0m Updating repository\033[0m"
  fi

  if [[ "${VERSION_CURRENT}" != "${VERSION_NEW}" ]] || [[ "${MD5_CURRENT}" != "${MD5_NEW}" ]]; then
    printf "\r\033[0;93m[REBOOT]\033[0m Updating repository\033[0m"
    if [[ "${VERBOSE}" == "1" ]]; then
      if [[ "${COMMAND}" != "" ]]; then
        printf "\n\033[0;94m[SCRIPT] ${COMMAND}\033[0m"
      fi

      if [[ "${OUTPUT}" != "" ]]; then
        printf "\n\033[0;94m[OUTPUT] %s\033[0m" "${OUTPUT[@]}"
      fi
    fi

    if [[ "${VERBOSE}" == "1" ]]; then
      printf "\n\033[0;94m[ INFO ] Local  ${VERSION_CURRENT}\033[0m"
      printf "\n\033[0;94m[ INFO ] Remote ${VERSION_NEW}\033[0m"
      printf "\n\033[0;94m[ INFO ] Script ${MD5_CURRENT}\033[0m"
      printf "\n\033[0;94m[ INFO ] Latest ${MD5_NEW}\033[0m"
    fi

    if [[ "${VERBOSE}" != "-1" ]]; then
      printf "\n"
    fi

    exec ${0} -Q ${ARGS_ALL}
  fi
else
  if [[ "${VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;93m[ SKIP ]\033[0m Updating repository\033[0m"
  fi
fi

if [[ "${VERBOSE}" != "-1" ]]; then
  if [[ "${VERBOSE}" == "1" ]]; then
    printf "\n\033[0;94m[ INFO ] Local  ${VERSION_CURRENT}\033[0m"
    printf "\n\033[0;94m[ INFO ] Script ${MD5_CURRENT}\033[0m"
  fi

  printf "\n\033[0;92m[  ..  ]\033[0m Running install script\033[0m"
fi

if [[ -x "${INSTALL_SCRIPTS}${OS_PREFIX}" ]]; then
  if [[ "${VERBOSE}" != "-1" ]]; then
    printf "\033[0;93m\r[UPDATE]\033[0m Running install script\033[0m"
  fi

  COMMAND="${INSTALL_SCRIPTS}${OS_PREFIX} ${ARGS_INSTALL}"
  if [[ "${OS_PREFIX}" == "osx" ]]; then
    OUTPUT=$(bash -c "${COMMAND}" 2>&1)
    readarray -t OUTPUT <<< "${OUTPUT}"
  else
    if [[ "${EUID}" == 0 ]]; then
      OUTPUT=$(bash -c "sudo ${COMMAND}" 2>&1)
      readarray -t OUTPUT <<< "${OUTPUT}"
    else
      OUTPUT=$(bash -c "${COMMAND}" 2>&1)
      readarray -t OUTPUT <<< "${OUTPUT}"
    fi
  fi
fi

if [[ "${VERBOSE}" != "-1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Running install script\033[0m"
  if [[ "${VERBOSE}" == "1" ]]; then
    if [[ "${COMMAND}" != "" ]]; then
      printf "\n\033[0;94m[SCRIPT] ${COMMAND}\033[0m"
    fi

    if [[ "${OUTPUT}" != "" ]]; then
      printf "\n\033[0;94m[OUTPUT] %s\033[0m" "${OUTPUT[@]}"
    fi
  fi
fi

for CONF in ${DEFAULT_CONFIG_PREFIX} ${OS_PREFIX}.${INSTALL_CONFIG_PREFIX} ${OS_PREFIX} ${FINAL_CONFIG_PREFIX} "${@}"; do
  if [[ ! -f "${DEPLOY_DIR}/${CONF}${CONF_SUFFIX}" ]]; then
    continue
  fi

  if [[ "${VERBOSE}" != "-1" ]]; then
    printf "\n\033[0;93m[UPDATE]\033[0m Running $CONF\033[0m"
  fi

  COMMAND="${DOT_BOT_DIR}/${DOT_BOT_BIN} -d \"${BASE_DIR}\" -c \"${DEPLOY_DIR}/${CONF}${CONF_SUFFIX}\""
  OUTPUT=$(bash -c "${COMMAND}" 2>&1)
  readarray -t OUTPUT <<< "${OUTPUT}"

  if [[ "${?}" != "0" ]]; then
    printf "\r\033[0;91m[FAILED]\033[0m Running $CONF\033[0m"
    if [[ "${VERBOSE}" == "1" ]]; then
      printf "\n\033[0;94m[SCRIPT] ${COMMAND}\033[0m"
      if [[ "${OUTPUT}" != "" ]]; then
        printf "\n\033[0;94m[OUTPUT] %s\033[0m" "${OUTPUT[@]}"
      fi
    fi

    printf "\n"
    exit 1
  fi

  if [[ "${VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;92m[  OK  ]\033[0m Running $CONF\033[0m"
    if [[ "${VERBOSE}" == "1" ]]; then
      if [[ "${COMMAND}" != "" ]]; then
        printf "\n\033[0;94m[SCRIPT] ${COMMAND}\033[0m"
      fi

      if [[ "${OUTPUT}" != "" ]]; then
        printf "\n\033[0;94m[OUTPUT] %s\033[0m" "${OUTPUT[@]}"
      fi
    fi
  fi
done

if [[ "${VERBOSE}" != "-1" ]]; then
  printf "\n"
fi

unset ARGS_ALL
unset ARGS_INSTALL
unset BASE_DIR
unset COMMAND
unset CONF_SUFFIX
unset DEFAULT_CONFIG_PREFIX
unset DEPLOY_DIR
unset DOT_BOT_BIN
unset DOT_BOT_DIR
unset DOT_BOT_PLUG
unset FINAL_CONFIG_PREFIX
unset FORCE
unset INSTALL_CONFIG_PREFIX
unset OPTIND
unset OUTPUT
unset REMOTE_REPO
unset UPDATE
unset VERBOSE
unset VERSION_CURRENT
unset VERSION_NEW
