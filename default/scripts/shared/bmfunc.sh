#!/usr/bin/env bash
# Check if command exists
function bm_command_check() {
  command -v "$1" &> /dev/null
  return $?
}

# Execute command and store results
function bm_command_execute() {
  BM_COMMAND="$1"
  if [[ ${BM_COMMAND} != sudo* ]]; then
    if [[ "${BM_USE_SUDO}" == "1" ]]; then
      BM_COMMAND="sudo -u ${BM_USER} ${BM_COMMAND}"
    fi
  fi

  bm_write_log "${BM_COMMAND}"
  BM_OUTPUT=$(bash -c "${BM_COMMAND}" 2>&1)
  bm_write_log "${BM_OUTPUT}"
}

# Execute command and return output
function bm_command_exit_code() {
  BM_COMMAND="$1"
  if [[ ${BM_COMMAND} != sudo* ]]; then
    if [[ "${BM_USE_SUDO}" == "1" ]]; then
      BM_COMMAND="sudo -u ${BM_USER} ${BM_COMMAND}"
    fi
  fi
  bash -c "${BM_COMMAND}" &>/dev/null
  echo $?
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
    mapfile -t OUTPUT < <(printf "%s" "${BM_OUTPUT}")
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
    mapfile -t OUTPUT < <(printf "%s" "${BM_OUTPUT}")
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
  unset BM_FORCE
  unset BM_INIT
  unset BM_LOADED
  unset BM_LOG_FILE
  unset BM_LOG_TO_FILE
  unset BM_OS
  unset BM_OS_UPDATE
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

  export BM_OS
  bm_task_ok "OS detection ${BM_OS}"
}

# Initialize the script and set required variables
function bm_init() {
  if [[ -n "${BM_INIT+x}" ]]; then
    return 1
  fi

  if [[ -n "${LOG_FILE+x}" ]] && [[ -n "${BM_LOG_TO_FILE+x}" ]]; then
    export BM_LOG_TO_FILE="1"
    export BM_LOG_FILE="${LOG_FILE}"
  fi

  if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
    export BM_VERBOSE=1
  fi

  export BM_USE_SUDO=0
  export BM_INIT=1
}

# Create new directory and set permissions
function bm_make_dir() {
  if [[ "$1" == "" ]]; then
    return
  fi

  BM_COMMAND="mkdir -p $1"
  if [[ "${BM_SUDO}" == "1" ]]; then
    BM_COMMAND="sudo -u ${BM_USER} ${BM_COMMAND}"
  fi

  BM_OUTPUT=$(bash -c "${BM_COMMAND}" 2>&1)
  BM_COMMAND="chown -R ${BM_USER}:${BM_USER} $1"
  if [[ "${BM_SUDO}" == "1" ]]; then
    BM_COMMAND="sudo -u ${BM_USER} ${BM_COMMAND}"
  fi

  BM_OUTPUT=$(bash -c "${BM_COMMAND}" 2>&1)
  unset BM_OUTPUT
  unset BM_COMMAND
}

# Print info message
function bm_print_info() {
  if [[ "${BM_VERBOSE}" == "1" ]]; then
    printf "\n\033[0;94m[ INFO ]\033[3;90m %s\033[0m" "$1"
  fi

  bm_write_log "$1"
}

# Print title
function bm_print_title() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\033[0;92m[ PROG ]\033[0;90m %s\033[0m" "$1"
  fi

  bm_write_log "$1"
}

# Execute script and store results
function bm_script_execute() {
  BM_COMMAND="$1"
  bm_write_log "${BM_COMMAND}"
  BM_OUTPUT=$(bash -c "${BM_COMMAND}" 2>&1)
  bm_write_log "${BM_OUTPUT}"
}

# Last script output
function bm_script_output() {
  if [[ "${BM_VERBOSE}" == "1" ]] && [[ "${BM_COMMAND}" != "" ]]; then
    printf "\n\033[0;94m[SCRIPT]\033[3;94m %s\033[0m" "${BM_COMMAND}"
  fi

  if [[ "${BM_VERBOSE}" == "1" ]] && [[ "${BM_OUTPUT}" != "" ]]; then
    mapfile -t OUTPUT < <(printf "%s" "${BM_OUTPUT}")
    printf "\n%s" "${OUTPUT[@]}"
    unset OUTPUT
  fi

  unset BM_COMMAND
  unset BM_OUTPUT
}

# Exit script with error
function bm_script_error() {
  if [[ "$1" != "" ]]; then
    printf "\r\033[0;91m[FAILED]\033[0;90m %s\033[0m" "$1"
  fi

  bm_de_init
  exit 1
}

# Update task status to error and exit
function bm_task_error() {
  printf "\r\033[0;91m[FAILED]\033[0;90m %s\033[0m" "$1"
  bm_de_init
  exit 1
}

# Update task status to failed
function bm_task_failed() {
  printf "\r\033[0;91m[FAILED]\033[0;90m %s\033[0m" "$1"
}

# Update status of last task to OK
function bm_task_ok() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;92m[  OK  ]\033[0;90m %s\033[0m" "$1"
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
    printf "\r\033[0;96m[ SKIP ]\033[0;90m %s\033[0m" "$1"
  fi
}

# Update task status to started
function bm_task_start() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\n\033[0;92m[  ..  ]\033[0;90m %s\033[0m" "$1"
  fi
}

# Update task status to in progress
function bm_task_update() {
  if [[ "${BM_VERBOSE}" != "-1" ]]; then
    printf "\r\033[0;93m[UPDATE]\033[0;90m %s\033[0m" "$1"
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

# Check if package is installed on ubuntu
function bm_ubuntu_package_installed() {
  dpkg-query -W --showformat='${Status}\n' "$1" &> /dev/null
  return $?
}

# Check if updates are available on ubuntu
function bm_ubuntu_update_check() {
  bm_task_start "Checking ubuntu updates"
  export BM_OS_UPDATE=0
  IFS=';' read -r UPD_COUNT SEC_COUNT < <(/usr/lib/update-notifier/apt-check 2>&1)
  local UPDATES=$((UPD_COUNT+SEC_COUNT))
  if [[ ${UPDATES} -ne 0 ]]; then
    export BM_OS_UPDATE=1
  fi

  bm_task_ok "Checking ubuntu updates"
  bm_print_info "Updates F: ${UPD_COUNT}"
  bm_print_info "Updates S: ${SEC_COUNT}"
  bm_print_info "Updates T: ${UPDATES}"
  bm_print_info "Update OS: ${BM_OS_UPDATE}"
}

# Write to log
function bm_write_log() {
  if [[ "${BM_LOG_TO_FILE}" == "1" ]] && [[ "$1" != "" ]]; then
    mapfile -t OUTPUT < <(printf "%s" "$1")
    printf "%s %s\n" "$(date +"[%Y-%m-%d %T]")" "${OUTPUT[@]}" >> "${BM_LOG_FILE}"
  fi
}

# Start script
export BM_SKIP=0
export BM_VERBOSE=0
export BM_ARGS=("$@")
while getopts "dflqs" OPT; do
  case "${OPT}" in
  d)
    export BM_VERBOSE=1
    ;;
  f)
    export BM_FORCE=1
    ;;
  l)
    export BM_LOG_TO_FILE=1
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