#!/usr/bin/env bash
# Check if command exists
function bm_command_check() {
  if [[ $(command -v "$1") != "" ]]; then
    return 1
  fi

  return 0
}

# Execute command and store results
function bm_command_execute() {
  BM_COMMAND="$1"
  if [[ "${BM_USE_SUDO}" == "1" ]]; then
    BM_COMMAND="sudo -u ${BM_USER} \"${BM_COMMAND}\""
  fi

  BM_OUTPUT=$(bash -c "${BM_COMMAND}" 2>&1)
}

# Locate command and print result
function bm_command_locate() {
  bm_task_start "Locating $1"
  if [[ $(command -v "$1") == "" ]]; then
    bm_task_error "Locating $1"
  fi

  bm_task_ok "Locating $1"
}

# Last command output
function bm_command_output_success() {
  if [[ "${BM_VERBOSE}" == "1" ]] && [[ "${BM_COMMAND}" != "" ]]; then
    printf "\n\033[0;94m[SCRIPT]\033[3;94m %s\033[0m" "${BM_COMMAND}"
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
function bm_command_output_error() {
  if [[ "${BM_COMMAND}" != "" ]]; then
    printf "\n\033[0;94m[SCRIPT]\033[3;94m %s\033[0m" "${BM_COMMAND}"
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

# Removes all variables and prints a new line
function bm_de_init() {
  unset BM_ARGS
  unset BM_COMMAND
  unset BM_INIT
  unset BM_LOADED
  unset BM_LOG_FILE
  unset BM_LOG_TO_FILE
  unset BM_OS
  unset BM_OUTPUT
  unset BM_SKIP
  unset BM_USER
  unset BM_USE_SUDO
  unset BM_VERBOSE
  printf "\033[0m\n"
}

# Detect OS current operating system
function bm_detect_os() {
  bm_task_start "OS detection"
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
    bm_task_error "OS detected ${OSTYPE}"
    ;;
  esac

  bm_task_ok "OS detection ${BM_OS}"
}

# Initialize the script and set required variables
function bm_init() {
  if [[ -n "${BM_INIT+x}" ]]; then
    return 1
  fi

  export BM_LOG_TO_FILE="0"
  if [[ -z "${LOG_FILE+x}" ]]; then
    export BM_LOG_TO_FILE="1"
    export BM_LOG_FILE="${LOG_FILE}"
  fi

  if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
    export BM_VERBOSE=1
  fi

  export BM_USE_SUDO=0
  export BM_INIT=1
}

# Print info message
function bm_print_info() {
  if [[ "${BM_VERBOSE}" == "1" ]]; then
    printf "\n\033[0;94m[ INFO ]\033[3;94m %s\033[0m" "$1"
  fi
}

# Print title
function bm_print_title() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\033[0;92m[ PROG ]\033[0;95m %s\033[0m" "$1"
  fi
}

# Exit script with error
function bm_script_error() {
  if [[ "$1" != "" ]]; then
    printf "\n\033[0;91m[FAILED]\033[0;97m %s\033[0m" "$1"
  fi

  bm_de_init
  exit 1
}

# Update task status to error and exit
function bm_task_error() {
  printf "\r\033[0;91m[FAILED]\033[0;97m %s\033[0m" "$1"
  bm_de_init
  exit 1
}

# Update task status to failed
function bm_task_failed() {
  printf "\r\033[0;91m[FAILED]\033[0;97m %s\033[0m" "$1"
}

# Update status of last task to OK
function bm_task_ok() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;92m[  OK  ]\033[0;97m %s\033[0m" "$1"
  fi
}

# Update status of last task to reboot
function bm_task_reboot() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;96m[REBOOT]\033[0;96m %s\033[0m" "$1"
  fi
}

# Update task status to skipped
function bm_task_skip() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;96m[ SKIP ]\033[0;96m %s\033[0m" "$1"
  fi
}

# Update task status to started
function bm_task_start() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\n\033[0;92m[  ..  ]\033[0;97m %s\033[0m" "$1"
  fi
}

# Update task status to in progress
function bm_update() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;93m[UPDATE]\033[0;97m %s\033[0m" "$1"
  fi
}

# Get current user
function bm_user_no_sudo() {
  export BM_USER=${USER}
  if [[ ${EUID} -eq 0 ]]; then
    bm_script_error "Running as sudo not supported"
  fi

  if groups "${USER}" | grep -q "\bsudo\b"; then
    export BM_USE_SUDO=1
  fi

  if groups "${USER}" | grep -q "\badmin\b"; then
    export BM_USE_SUDO=1
  fi
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
  *)
    bm_script_error
    ;;
  esac
done

shift $((OPTIND - 1))

[[ "${1:-}" == "--" ]] && shift

export BM_LOADED=1