#!/usr/bin/env bash
# Init functions
function bm_init () {
  if [[ ! -z "${BM_INIT+x}" ]]; then
    return 1
  fi

  export BM_LOG_TO_FILE="0"
  if [[ -z "${LOG_FILE+x}" ]]; then
    export BM_LOG_TO_FILE="1"
    export BM_LOG_FILE="${LOG_FILE}"
  fi

  if [[ ! -z "${VERBOSE_LOGIN+x}" ]]; then
    export BM_VERBOSE=1
  fi

  export BM_INIT=1
}

# Deinit functions
function bm_deinit () {
  unset BM_ARGS
  unset BM_COMMAND
  unset BM_LOADED
  unset BM_LOG_FILE
  unset BM_LOG_TO_FILE
  unset BM_INIT
  unset BM_SKIP
  unset BM_OUTPUT
  unset BM_OS
  unset BM_USER
  unset BM_VERBOSE
  printf "\033[0m\n"
}

# Check if command exists
function bm_check () {
  if [[ $(command -v $@) != "" ]]; then
    return 1
  fi

  return 0
}

# Complete last task
function bm_complete () {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;92m[  OK  ]\033[0;97m $@\033[0m"
  fi
}

# Detect OS
function bm_detect_os () {
  bm_progress "OS detection"
  case "${OSTYPE}" in
    "darwin"*)
      BM_OS='osx'
      ;;
    "linux-gnu")
      BM_OS=$(grep </etc/os-release "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
      ;;
    "linux-gnueabihf")
      BM_OS=$(grep </etc/os-release "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
      ;;
    *)
      bm_error "OS detected ${OSTYPE}"
      ;;
  esac

  bm_complete "OS detection ${BM_OS}"
}

# Execute command
function bm_execute() {
  BM_COMMAND="$@"
  if [[ "${EUID}" == "0" ]]; then
    BM_COMMAND="sudo -u ${BM_USER} $@"
  fi

  BM_OUTPUT=$(bash -c "${BM_COMMAND}" 2>&1)
}

# Exit with error
function bm_error () {
  printf "\r\033[0;91m[FAILED]\033[0;97m $@\033[0m"
  bm_deinit
  exit 1
}

function bm_error_exit () {
  bm_deinit
  exit 1
}

function bm_failed () {
  printf "\r\033[0;91m[FAILED]\033[0;97m $@\033[0m"
}

# Print info
function bm_info () {
  if [[ "${BM_VERBOSE}" == "1" ]]; then
    printf "\n\033[0;94m[ INFO ]\033[3;94m $@\033[0m"
  fi
}

# Last command output
function bm_last_command () {
  if [[ "${BM_VERBOSE}" == "1" ]] && [[ "${BM_COMMAND}" != "" ]]; then
    printf "\n\033[0;94m[SCRIPT]\033[3;94m ${BM_COMMAND}\033[0m"
  fi

  if [[ "${BM_VERBOSE}" == "1" ]] && [[ "${BM_OUTPUT}" != "" ]]; then
    IFS=$'\n'
    OUTPUT=("${BM_OUTPUT}")
    printf "\n\033[0;94m[OUTPUT]\033[3;94m %s\033[0m" "${OUTPUT[@]}"
    unset OUTPUT
  fi

  unset BM_COMMAND
  unset BM_OUTPUT
}

# Last command error
function bm_last_error () {
  if [[ "${BM_COMMAND}" != "" ]]; then
    printf "\n\033[0;94m[SCRIPT]\033[3;94m ${BM_COMMAND}\033[0m"
  fi

  if [[ "${BM_OUTPUT}" != "" ]]; then
    IFS=$'\n'
    OUTPUT=("${BM_OUTPUT}")
    printf "\n\033[0;91m[FAILED]\033[3;91m %s\033[0m" "${OUTPUT[@]}"
    unset OUTPUT
  fi

  unset BM_COMMAND
  unset BM_OUTPUT
}

# Locate command
function bm_locate () {
  bm_progress "Locating $@"
  if [[ $(command -v $@) == "" ]]; then
    bm_error "Locating $@"
  fi

  bm_complete "Locating $@"
}

# Print restart
function bm_reboot () {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;96m[REBOOT]\033[0;96m $@\033[0m"
  fi
}

# Print skipped
function bm_skip () {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;96m[ SKIP ]\033[0;96m $@\033[0m"
  fi
}

# Print title
function bm_title () {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\033[0;92m[ PROG ]\033[0;95m $@\033[0m"
  fi
}

# Print progress
function bm_progress () {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\n\033[0;92m[  ..  ]\033[0;97m $@\033[0m"
  fi
}

# Update last task
function bm_update () {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;93m[UPDATE]\033[0;97m $@\033[0m"
  fi
}

# Get current user
function bm_user () {
  bm_info "User\t${USER}"
  bm_info "Sudo\t${SUDO_USER}"
  bm_info "UEID\t${EUID}"
  export BM_USER=${USER}
  if [[ "${EUID}" == "0" ]]; then
    export BM_USER=${SUDO_USER}
  fi

  bm_info "BM User\t${BM_USER}"
}

# Write to log

# Start script
export BM_SKIP=0
export BM_VERBOSE=0
export BM_ARGS=$@
while getopts "dfqs" OPT; do
  case "${OPT}" in
    d)
      export BM_VERBOSE=1
      ;;
    f)
      export BM_VERBOSE=1
      ;;
    q)
      export BM_VERBOSE=-1
      ;;
    s)
      export BM_SKIP=1
      ;;
  esac
done

shift $((OPTIND-1))

[[ "${1:-}" = "--" ]] && shift

bm_user
export BM_LOADED=1
