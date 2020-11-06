#!/usr/bin/env bash
# TODO Implement check sude
DEPLOY_ROOT=$HOME/.deploy
DEPLOY_LOG_FILE=deploy.log
DEPLOY_LOG=$DEPLOY_ROOT/log/$DEPLOY_LOG_FILE
DEPLOY_OS=
DISPLAY_DEPLOY_OS=

function dir_check() {
  local DIR=$1
  local NEW=$2
  if [ ! -d "$DIR" ] && [ -n "$NEW" ]; then
    return 1
  fi

  if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
    return 0
  fi

  return 0
}

function check_file() {
  local FILE_DIR=$1
  local FILE_CHECK=$2
  local CHECK_FILE=
  local LOG_STG=UPDATE
  CHECK_FILE=$FILE_DIR/$FILE_CHECK
  if [[ ! -f "$CHECK_FILE" ]]; then
    touch "$CHECK_FILE"
  fi

  return 0
}

function check_logfile() {
  local FILE_DIR=$1
  local DEPLOY_LOG=$2
  if dir_check "$FILE_DIR"; then
    check_file "$FILE_DIR" "$DEPLOY_LOG"
  fi

  return 0
}

function check_os() {
  local DISPLAY_DEPLOY_OS=
  case "$DEPLOY_OSTYPE" in
  "darwin"*)
    DISPLAY_DEPLOY_OS='osx'
    ;;
  "linux-gnu")
    DISPLAY_DEPLOY_OS=$(grep </etc/os-release "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
    ;;
  esac
  echo "$DISPLAY_DEPLOY_OS"
  return 0
}

function check_shell() {
  local FILE_DIR=$2
  local LOCK_FILE=$FILE_DIR/update_lock.pid
  local LOG_STG=UPDATE
  local DISPLAY_DEPLOY_OS=$1
  if [ -f "$LOCK_FILE" ]; then
    write_log "$LOG" "$LOG_STG" "Script is running already"
    output_clear
    exit 0
  fi

  if [ -z "$DISPLAY_DEPLOY_OS" ]; then
    write_log "$LOG" "$LOG_STG" "Unsupported DEPLOY_OS"
    output_busy 255 "$DEPLOY_OS_UPPER" "UNSUPPORTED DEPLOY_OS"
    update_cleanup "$FILE_DIR"
    exit 255
  fi

  if [ -n "$TMUX" ]; then
    write_log "$LOG" "$LOG_STG" "Detected TMUX"
    update_cleanup "$FILE_DIR"
    output_clear
    exit 0
  fi

  if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    write_log "$LOG" "$LOG_STG" "Detected VSCODE"
    update_cleanup "$FILE_DIR"
    output_clear
    exit 0
  fi
}

function format_arg() {
  local ARG_LEN=
  local ARG_PAD=$2
  local ARG_VALUE=$1
  local FMT_VALUE=
  local FMT=
  local PAD_LEFT=
  local PAD_MIN=
  local PAD_ODD=
  local PAD_RIGHT=
  FMT_VALUE=${ARG_VALUE:0:ARG_PAD}
  ARG_LEN=${#FMT_VALUE}
  PAD_MIN=$(("$ARG_PAD" - "$ARG_LEN"))
  PAD_ODD=$((ARG_PAD % 2))
  if [[ $((PAD_MIN % 2)) -eq "1" ]]; then
    PAD_ODD=1
  fi

  PAD_LEFT=$(("$PAD_MIN" / 2))
  PAD_RIGHT=$PAD_LEFT
  PAD_RIGHT=$(("$PAD_RIGHT" + "$PAD_ODD"))
  FMT=$(printf "%-${PAD_LEFT}s%s%${PAD_RIGHT}s" "" "${FMT_VALUE}" "")
  echo "${FMT}"
  return 0
}

function lock_update() {
  local FILE_DIR=$1
  local LOG_STG=UPDATE
  local LOCK_FILE=$FILE_DIR/update_lock.pid
  if [ ! -f "$LOCK_FILE" ]; then
    write_log "$LOG" "$LOG_STG" "Creating lock file"
    echo $$ >"$LOCK_FILE"
  fi

  return 0
}

function output_busy() {
  local ARG_DEPLOY_OS=$2
  local ARG_PROG=$1
  local ARG_STAGE=$3
  local COL_CLR="\033[0m"
  local COL_GRN="\033[1;32m"
  local COL_MSG=
  local COL_STG=
  local COL_RED="\033[1;31m"
  local COL_YLW="\033[1;33m"
  local FMT_DEPLOY_OS=
  local FMT_STAGE=
  local LINE_FMT=
  local LINE_FMT="$LINE_REM::%10s\t:%15s::\n"
  local LINE_IND=
  local LINE_REM="\e[1A\e[K"
  case $ARG_PROG in
  0)
    COL_MSG=$COL_GRN
    COL_STG=$COL_GRN
    LINE_IND=:
    ;;
  1)
    COL_MSG=$COL_YLW
    COL_STG=$COL_GRN
    LINE_IND=-
    ;;
  2)
    COL_MSG=$COL_YLW
    COL_STG=$COL_GRN
    LINE_IND=/
    ;;
  3)
    COL_MSG=$COL_YLW
    COL_STG=$COL_GRN
    LINE_IND=\\
    ;;
  255)
    COL_MSG=$COL_RED
    COL_STG=$COL_RED
    LINE_IND=!
    ;;
  esac

  FMT_DEPLOY_OS=$(format_arg "$ARG_DEPLOY_OS" 12)
  FMT_STAGE=$(format_arg "$ARG_STAGE" 20)
  LINE_FMT="$LINE_REM$COL_CLR::$COL_MSG%c$COL_CLR:$COL_STG%s$COL_CLR:$COL_MSG%s$COL_CLR::\n"
  #shellcheck disable=SC2059
  printf "$LINE_FMT" "$LINE_IND" "$FMT_DEPLOY_OS" "$FMT_STAGE"
  return 0
}

function output_clear() {
  local LINE_REM="\e[1A\e[K"
  printf "$LINE_REM%s" ""
}

function update_cleanup() {
  local CLEAN_DIR=$1
  rm -rf "$CLEAN_DIR"
  unset DEPLOY_ROOT
  unset DEPLOY_LOG
  unset LOG
  return 0
}

function write_log() {
  local LOG_FILE=$1
  local LOG_STAGE=$2
  local LOG_MSG=$3
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "$LOG_MSG" >>"$LOG_FILE"
  return 0
}

function update_main() {
  local DIR_DOT_FILES=$HOME/.dotfiles
  local LOG_STG=UPDATE
  local STAGE=UPDATE
  DEPLOY_OS=$(check_os)
  DEPLOY_OS_UPPER=$(echo "$DEPLOY_OS" | awk '{print toupper($1)}')
  output_busy 1 "$DEPLOY_OS_UPPER" "VALIDATING"
  check_logfile "$DEPLOY_ROOT/log" "$DEPLOY_LOG"
  write_log "$LOG" "$LOG_STG" "Update Started"
  write_log "$LOG" "$LOG_STG" "Detected $DEPLOY_OS_UPPER"
  output_busy 2 "$DEPLOY_OS_UPPER" "VALIDATE SHELL"
  check_shell "$DEPLOY_OS" "$DEPLOY_ROOT"
  output_busy 1 "$DEPLOY_OS_UPPER" "DETERMINE STATUS"
  write_log "$LOG" "$LOG_STG" "Locking script"
  lock_update "$DEPLOY_ROOT"
  output_busy 2 "$DEPLOY_OS_UPPER" "DETERMINE TASKS"
  output_busy 0 "$DEPLOY_OS_UPPER" "COMPLETED"
  write_log "$LOG" "$LOG_STG" "Update Completed"
  update_cleanup "$DEPLOY_ROOT"
  output_clear
}

function deploy_prepare() {
  local LOG_STG=UPDATE
  local STAGE=UPDATE
  DEPLOY_OS=$(check_os)
  DEPLOY_OS_UPPER=$(echo "$DEPLOY_OS" | awk '{print toupper($1)}')
}

DEPLOY_START=[
  "deploy_prepare"
]
eval "$MAIN"
exit 0

APP_SUDO=$(which sudo | tee -a "$DEPLOY_LOG")
USER_IS_ROOT=false
USER_IS_SUDO=false
USER_ID=$(id -u "$USER" | tee -a "$DEPLOY_LOG")
if [[ $USER_ID == 0 ]]; then
  USER_IS_ROOT=true
  USER_IS_SUDO=true
elif [[ -x $APP_SUDO ]]; then
  case "$DISPLAY_DEPLOY_OS" in
  "osx")
    USER_IS_SUDO=$(groups "$USER" | tee -a "$DEPLOY_LOG" | grep -w admin)
    ;;
  "ubuntu")
    USER_IS_SUDO=$(groups "$USER" | tee -a "$DEPLOY_LOG" | grep -w sudo)
    ;;
  esac

  if [[ "$USER_IS_SUDO" != "" ]]; then
    USER_IS_SUDO=true
  fi
fi

FILE_ENV=$HOME/.environment.zsh
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_SUDO = $APP_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_ID = $USER_ID"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_IS_ROOT = $USER_IS_ROOT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_IS_SUDO = $USER_IS_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_ENV = $FILE_ENV"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if $FILE_ENV exists"
} >>"$DEPLOY_LOG"

unset COLORTERM
unset DEFAULT_USER
unset DISABLE_AUTO_UPDATE
unset ITERM2_SQUELCH_MARK
unset KEYTIMEOUT
if [[ ! -f $FILE_ENV ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Creating $FILE_ENV" >>"$DEPLOY_LOG"
  touch "$FILE_ENV"
fi

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Sourcing $FILE_ENV" >>"$DEPLOY_LOG"
# shellcheck source=/dev/null
source "$FILE_ENV"
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "COLORTERM = $COLORTERM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DEFAULT_USER = $DEFAULT_USER"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DISABLE_AUTO_UPDATE = $DISABLE_AUTO_UPDATE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "ITERM2_SQUELCH_MARK = $ITERM2_SQUELCH_MARK"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "KEYTIMEOUT = $KEYTIMEOUT"
} >>"$DEPLOY_LOG"

if [[ -z $COLORTERM ]]; then
  echo "export COLORTERM=truecolor" >>"$FILE_ENV"
fi

if [[ $USER_IS_ROOT == false ]] && [[ -z $DEFAULT_USER ]]; then
  echo "export DEFAULT_USER=$(whoami | tee -a "$DEPLOY_LOG")" >>"$FILE_ENV"
fi

if [[ -z $DISABLE_AUTO_UPDATE ]]; then
  echo "export DISABLE_AUTO_UPDATE=true" >>"$FILE_ENV"
fi

if [[ -z $ITERM2_SQUELCH_MARK ]]; then
  echo "export ITERM2_SQUELCH_MARK=1" >>"$FILE_ENV"
fi

if [[ -z $KEYTIMEOUT ]]; then
  echo "export KEYTIMEOUT=1" >>"$FILE_ENV"
fi

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Sourcing $FILE_ENV" >>"$DEPLOY_LOG"
# shellcheck source=/dev/null
source "$FILE_ENV"
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "COLORTERM = $COLORTERM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DEFAULT_USER = $DEFAULT_USER"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DISABLE_AUTO_UPDATE = $DISABLE_AUTO_UPDATE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "ITERM2_SQUELCH_MARK = $ITERM2_SQUELCH_MARK"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "KEYTIMEOUT = $KEYTIMEOUT"
} >>"$DEPLOY_LOG"
unset FILE_ENV
unset USER_ID
unset USER_IS_ROOT

STAGE="DOT FILES"
LOG_STAGE="DOTFILE"
printf "$LINE_REM$COL_CLR::$COL_GRN$DISPLAY_DEPLOY_OS_UPPER$COL_CLR:_::\t$COL_YLW%s\t$COL_CLR::\n" "$STAGE"
exit 20
APP_GIT=$(which git | tee -a "$DEPLOY_LOG")
DOT_FILES_CONFIGURE=false
DOT_FILES_INSTALL=false
DOT_FILES_UPDATE=false
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DIR_DOT_FILES = $DIR_DOT_FILES" >>"$DEPLOY_LOG"
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check if $DIR_DOT_FILES exists" >>"$DEPLOY_LOG"
if [[ -d $DIR_DOT_FILES ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Update $DIR_DOT_FILES" >>"$DEPLOY_LOG"
  DOT_FILES_UPDATE=true
else
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Install $DIR_DOT_FILES" >>"$DEPLOY_LOG"
  DOT_FILES_INSTALL=true
fi

{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if git is installed"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_GIT = $APP_GIT"
} >>"$DEPLOY_LOG"
if [[ -z $APP_GIT ]]; then
  DOT_FILES_UPDATE=false
  DOT_FILES_INSTALL=false
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPED: git not installed" >>"$DEPLOY_LOG"
  printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\t%s$COL_CLR\n" "SKIPPING" "git mising"
fi

{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if git is installed"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_GIT = $APP_GIT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_CONFIGURE = $DOT_FILES_CONFIGURE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_INSTALL = $DOT_FILES_INSTALL"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_UPDATE = $DOT_FILES_UPDATE"
} >>"$DEPLOY_LOG"
if [[ $DOT_FILES_INSTALL == true ]]; then
  echo -e "$DOT_FILES_INSTALL\n"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Installing $DIR_DOT_FILES" >>"$DEPLOY_LOG"
  printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "INSTALL"
  if ! eval "$APP_GIT" clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git clone failed" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_RED ! $COL_CLR$STAGE\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "git clone failed"
    exit 255
  fi

  DOT_FILES_CONFIGURE=true
  unset DOT_FILES_INSTALL
fi

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_CONFIGURE = $DOT_FILES_CONFIGURE" >>"$DEPLOY_LOG"
printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
if [[ $DOT_FILES_UPDATE == true ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if $DIR_DOT_FILES needs updating" >>"$DEPLOY_LOG"
  pushd "$DIR_DOT_FILES" >/dev/null || return
  read -r CURRENT_BRANCH < <(eval "$APP_GIT" branch | tee -a "$DEPLOY_LOG" | cut -d ' ' -f 2)
  if ! read -r CURRENT_HEAD < <(eval "$APP_GIT" log --pretty=%H ...refs/heads/"$CURRENT_BRANCH"^ | tee -a "$DEPLOY_LOG"); then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git log failed" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_RED ! $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "git log failed"
    exit 255
  fi

  if ! read -r REMOTE_HEAD < <(eval "$APP_GIT" ls-remote origin -h refs/heads/"$CURRENT_BRANCH" | tee -a "$DEPLOY_LOG" | cut -f1); then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git ls-remote failed" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_RED ! $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "git ls-remote failed"
    exit 255
  fi

  {
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "CURRENT_BRANCH = $CURRENT_BRANCH"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "CURRENT_HEAD = $CURRENT_HEAD"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "REMOTE_HEAD = $REMOTE_HEAD"
  } >>"$DEPLOY_LOG"
  if [[ "$CURRENT_HEAD" != "$REMOTE_HEAD" ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Updating $DIR_DOT_FILES" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "UPDATE"
    DOT_FILES_CONFIGURE=true
    if ! eval "$APP_GIT" pull 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git pull failed" >>"$DEPLOY_LOG"
      printf "$LINE_REM$COL_RED ! $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "git pull failed"
      exit 255
    fi
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | tee -a "$DEPLOY_LOG" | wc -l); then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git status failed" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_RED ! $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "git status failed"
    exit 255
  fi

  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_PUSH = $DOT_FILES_PUSH" >>"$DEPLOY_LOG"
  if [[ $DOT_FILES_PUSH -gt 0 ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Reconfigure $DIR_DOT_FILES due to local changes" >>"$DEPLOY_LOG"
    DOT_FILES_CONFIGURE=true
  fi

  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_CONFIGURE = $DOT_FILES_CONFIGURE" >>"$DEPLOY_LOG"
  popd >/dev/null || return
  unset CURRENT_HEAD
  unset DOT_FILES_PUSH
  unset DOT_FILES_UPDATE
  unset REMOTE_HEAD
fi

printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
if [[ $DOT_FILES_CONFIGURE == true ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Determining if installer can be run" >>"$DEPLOY_LOG"
  pushd "$DIR_DOT_FILES" >/dev/null || return
  DOT_FILES_INSTALLER=$HOME/.dotfiles/install
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_INSTALLER = $DOT_FILES_INSTALLER" >>"$DEPLOY_LOG"
  if [[ ! -x "$DOT_FILES_INSTALLER" ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "install script missing" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_RED ! $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "install script missing"
    exit 255
  fi

  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Running $DOT_FILES_INSTALLER" >>"$DEPLOY_LOG"
  printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "INSTALLER"
  if ! eval "$DOT_FILES_INSTALLER" 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null 2>&1; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "install script failed" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_RED ! $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "install script failed"
    exit 255
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | tee -a "$DEPLOY_LOG" | wc -l); then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "status failed failed" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_RED ! $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" " git status failed"
    exit 255
  fi

  popd >/dev/null || return
fi

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_PUSH = $DOT_FILES_PUSH" >>"$DEPLOY_LOG"
printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\n" "OK"

unset DIR_DOT_FILES
unset DOT_FILES_CONFIGURE
unset DOT_FILES_INSTALLER

STAGE="Verifying packages"
LOG_STAGE="PACKAGE"
printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
case "$DISPLAY_DEPLOY_OS" in
"osx")
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Processing operating system $DISPLAY_DEPLOY_OS" >>"$DEPLOY_LOG"
  APP_BREW=$(which brew | tee -a "$DEPLOY_LOG")
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_BREW = $APP_BREW" >>"$DEPLOY_LOG"
  if [[ ! -x $APP_BREW ]]; then
    APP_RUBY=$(which ruby | tee -a "$DEPLOY_LOG")
    if [[ -z $APP_RUBY ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPING ruby missing" >>"$DEPLOY_LOG"
      printf "$LINE_REM$COL_GRN::: $COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\t%s$COL_CLR\n" "SKIPPING" "ruby missing"
      exit 255
    fi

    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Running $APP_RUBY" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "INSTALL"
    if ! eval CI=1 "$APP_RUBY" -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "install brew failed" >>"$DEPLOY_LOG"
      printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "install brew failed"
    fi

    unset APP_RUBY
  fi

  printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
  APP_BREW=$(which brew | tee -a "$DEPLOY_LOG")
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_BREW = $APP_BREW" >>"$DEPLOY_LOG"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Run $APP_BREW update" >>"$DEPLOY_LOG"
  if ! eval "$APP_BREW" update 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "brew update failed" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "brew update failed"
    exit 255
  fi

  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check for outdated packages" >>"$DEPLOY_LOG"
  read -r BREW_UPDATES < <(eval "$APP_BREW" outdated 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null)
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_UPDATES = $BREW_UPDATES" >>"$DEPLOY_LOG"
  if [[ -n "$BREW_UPDATES" ]]; then
    BREW_CLEAN=true
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Run $APP_BREW upgrade" >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "UPGRADE"
    if ! eval "$APP_BREW" upgrade &>/dev/null | tee -a "$DEPLOY_LOG"; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "brew upgrade failed" >>"$DEPLOY_LOG"
      printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "brew upgrade failed"
      exit 255
    fi
  fi
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_CLEAN = $BREW_CLEAN" >>"$DEPLOY_LOG"

  unset BREW_UPDATES
  printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
  FILE_CHECKSUM=$HOME/.packages/checksum
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_CHECKSUM = $FILE_CHECKSUM" >>"$DEPLOY_LOG"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check if $FILE_CHECKSUM exists" >>"$DEPLOY_LOG"
  if [[ ! -f $FILE_CHECKSUM ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Create $FILE_CHECKSUM" >>"$DEPLOY_LOG"
    touch "$FILE_CHECKSUM"
  fi

  {
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_CLEAN = $BREW_CLEAN" >>"$DEPLOY_LOG"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Loading $FILE_CHECKSUM"
  } >>"$DEPLOY_LOG"
  # shellcheck source=/dev/null
  source "$FILE_CHECKSUM"
  FILE_BREW_APPS=$HOME/.packages/brew
  {
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_BREW_APPS = $FILE_BREW_APPS"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check if $FILE_BREW_APPS exists"
  } >>"$DEPLOY_LOG"
  if [[ -f $FILE_BREW_APPS ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Processing $FILE_BREW_APPS" >>"$DEPLOY_LOG"
    MD5=
    case "$DISPLAY_DEPLOY_OS" in
    "osx")
      MD5=$(which md5 | tee -a "$DEPLOY_LOG")
      MD5="$MD5 -r"
      ;;
    "ubuntu")
      MD5=$(which md5sum | tee -a "$DEPLOY_LOG")
      ;;
    esac
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5 = $MD5" >>"$DEPLOY_LOG"
    read -r MD5_HASH < <(eval "$MD5" "$FILE_BREW_APPS" | tee -a "$DEPLOY_LOG" | cut -d ' ' -f 1)
    {
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_HASH = $MD5_HASH"
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_BREW = $MD5_BREW"
    } >>"$DEPLOY_LOG"
    if [[ "$MD5_HASH" != "$MD5_BREW" ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "$FILE_BREW_APPS changed" >>"$DEPLOY_LOG"
      BREW_CLEAN=true
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_CLEAN = $BREW_CLEAN" >>"$DEPLOY_LOG"
      while IFS="" read -r APP || [ -n "$APP" ]; do
        BREW_APP=
        BREW_ARGS=
        BREW_APP=$(echo "$APP" | tee -a "$DEPLOY_LOG" | cut -d ',' -f 1)
        if [[ $APP == *","* ]]; then
          BREW_ARGS="--$(echo "$APP" | tee -a "$DEPLOY_LOG" | cut -d ',' -f 2)"
        fi

        read -r BREW_INSTALL < <("$APP_BREW" ls --versions "$BREW_APP")
        {
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP = $APP"
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_APP = $BREW_APP"
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_ARGS = $BREW_ARGS"
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_INSTALL = $BREW_INSTALL"
        } >>"$DEPLOY_LOG"
        if [[ -z "$BREW_INSTALL" ]]; then
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Installing $BREW_APP" >>"$DEPLOY_LOG"
          printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\t%s$COL_CLR\n" "INSTALL" "$BREW_APP"
          if ! eval "$APP_BREW" install "$BREW_ARGS" "$BREW_APP" 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null; then
            printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "brew install $BREW_APP failed" >>"$DEPLOY_LOG"
            printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "brew install $BREW_APP failed"
            exit 255
          fi
        fi

        printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
        unset BREW_APP
        unset BREW_ARGS
        unset BREW_INSTALL
      done <"$FILE_BREW_APPS"

      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Updating checksum" >>"$DEPLOY_LOG"
      if [[ -z "$MD5_BREW" ]]; then
        echo "export MD5_BREW=$MD5_HASH" >>"$FILE_CHECKSUM"
      else
        sed -i '' "s/$MD5_BREW/$MD5_HASH/" "$FILE_CHECKSUM"
      fi
    fi
  fi

  unset MD5_HASH
  unset MD5
  printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
  if [[ $BREW_CLEAN == true ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Running $APP_BREW cleanup" >>"$DEPLOY_LOG"
    if ! eval "$APP_BREW" cleanup 2>&1 | tee "$DEPLOY_LOG" >/dev/null; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "brew cleanup failed" >>"$DEPLOY_LOG"
      printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "brew cleanup failed"
      exit 255
    fi
  fi

  printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\n" "OK"
  unset BREW_CLEAN
  unset FILE_CHECKSUM
  unset FILE_BREW_APPS
  unset APP_BREW
  ;;
"ubuntu")
  if [[ $USER_IS_SUDO == false ]]; then
    printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\t%s$COL_CLR\n" "SKIPPING" "sudo required"
  else
    APP_SUDO=$(which sudo | tee -a "$DEPLOY_LOG")
    if [[ ! -x $APP_SUDO ]]; then
      printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "sudo missing"
      exit 255
    fi

    APP_APT=$(which apt-get | tee -a "$DEPLOY_LOG")
    if [[ ! -x $APP_APT ]]; then
      printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "apt-get missing"
      exit 255
    fi

    if ! eval "$APP_SUDO" -E -n "$APP_APT" -qq update; then
      printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "apt-get update failed"
      exit 255
    fi

    read -r APT_UPDATE < <(eval "$APP_SUDO" -E -n "$APP_APT" -qq upgrade --dry-run)
    if [[ -n $APT_UPDATE ]]; then
      APT_CLEAN=true
      if ! eval "$APP_SUDO" -E -n "$APP_APT" -qq upgrade -y &>/dev/null; then
        printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "apt-get upgrade failed"
        exit 255
      fi

      unset APT_UPDATE
      read -r APT_UPDATE < <(eval "$APP_SUDO" -E -n "$APP_APT" -qq dist-upgrade --dry-run)
      if [[ -n $APT_UPDATE ]]; then
        APT_CLEAN=true
        if ! eval "$APP_SUDO" -E -n "$APP_APT" -qq dist-upgrade -y &>/dev/null; then
          printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "apt-get dist-upgrade failed"
          exit 255
        fi

        unset APT_UPDATE
      fi

      if [[ $APT_CLEAN == true ]]; then
        if eval "$APP_SUDO" -E -n "$APP_APT" -qq autoremove -y &>/dev/null; then
          printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "apt-get autoremove failed"
          exit 255
        fi

        if eval "$APP_SUDO" -E -n "$APP_APT" -qq autoclean -y &>/dev/null; then
          printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "apt-get autoremove failed"
          exit 255
        fi
      fi

      unset APT_CLEAN
      unset APP_APT
      unset APP_SUDO
    fi

    printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\n" "OK"
  fi
  ;;
esac

STAGE="Verifying node"
LOG_STAGE="NODE"
printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
FILE_CHECKSUM=$HOME/.packages/checksum
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_CHECKSUM = $FILE_CHECKSUM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if $FILE_CHECKSUM exists"
} >>"$DEPLOY_LOG"
if [[ ! -f $FILE_CHECKSUM ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Creating $FILE_CHECKSUM" >>"$DEPLOY_LOG"
  touch "$FILE_CHECKSUM"
fi

APP_NODE=$(which node | tee -a "$DEPLOY_LOG")
APP_NPM=$(which npm | tee -a "$DEPLOY_LOG")
NEED_SUDO=false
USE_SUDO=
if [[ "$DISPLAY_DEPLOY_OS" == "ubuntu" ]] && [[ $USER_IS_SUDO == true ]]; then
  USE_SUDO="$APP_SUDO -E -n "
elif [[ "$DISPLAY_DEPLOY_OS" == "ubuntu" ]]; then
  NEED_SUDO=true
fi

{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_NODE = $APP_NODE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_NPM = $APP_NPM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NEED_SUDO = $NEED_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USE_SUDO = $USE_SUDO"
} >>"$DEPLOY_LOG"
if [[ $NEED_SUDO == false ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Node does not require sudo or sudo enabled" >>"$DEPLOY_LOG"
  if [[ -x $APP_NODE ]] && [[ -x $APP_NPM ]]; then
    read -r NODE_PATH < <(eval "$USE_SUDO$APP_NPM" -g root | tee -a "$DEPLOY_LOG")
    {
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_PATH = $NODE_PATH"
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking for node outdated packages"
    } >>"$DEPLOY_LOG"
    eval "$USE_SUDO$APP_NPM" -g list outdated --depth=0 --parseable | tee -a "$DEPLOY_LOG" | while read -r LINE; do
      {
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "LINE = $LINE"
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "LINE LENGTH = ${#LINE}"
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_PATH LENGTH = ${#NODE_PATH}"
      } >>"$DEPLOY_LOG"
      if [[ ${#LINE} -gt ${#NODE_PATH} ]]; then
        NODE_APP=${LINE/$NODE_PATH/}
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_APP = $NODE_APP" >>"$DEPLOY_LOG"
        if [[ -n "$NODE_APP" ]]; then
          NODE_APP=$(echo -e "$NODE_APP" | tee -a "$DEPLOY_LOG" | rev | cut -d '/' -f 1 | rev)
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Update $NODE_APP" >>"$DEPLOY_LOG"
          printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\t%s$COL_CLR\n" "UPDATE" "$NODE_APP"
          if ! eval "$USE_SUDO$APP_NPM" -g install --upgrade "$NODE_APP" 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null; then
            printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "npm -g install --upgrade $NODE_APP failed" >>"$DEPLOY_LOG"
            printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "npm -g install --upgrade $NODE_APP failed"
            exit 255
          fi

          printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
          unset NODE_APP
        fi
      fi
    done

    printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Loading $FILE_CHECKSUM" >>"$DEPLOY_LOG"
    # shellcheck source=/dev/null
    source "$FILE_CHECKSUM"
    FILE_NODE_APPS=$HOME/.packages/node
    {
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_NODE_APPS = $FILE_NODE_APPS"
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check if $FILE_NODE_APPS exists"
    } >>"$DEPLOY_LOG"
    if [[ -f $FILE_NODE_APPS ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Processing $FILE_NODE_APPS" >>"$DEPLOY_LOG"
      MD5=
      case "$DISPLAY_DEPLOY_OS" in
      "osx")
        MD5=$(which md5 | tee -a "$DEPLOY_LOG")
        MD5="$MD5 -r"
        ;;
      "ubuntu")
        MD5=$(which md5sum | tee -a "$DEPLOY_LOG")
        ;;
      esac
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5 = $MD5" >>"$DEPLOY_LOG"
      read -r MD5_HASH < <(eval "$MD5" "$FILE_NODE_APPS" | cut -d ' ' -f 1)
      {
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_HASH = $MD5_HASH"
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_NODE = $MD5_NODE"
      } >>"$DEPLOY_LOG"
      if [[ "$MD5_HASH" != "$MD5_NODE" ]]; then
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "$FILE_NODE_APPS changed" >>"$DEPLOY_LOG"
        while IFS="" read -r APP || [ -n "$APP" ]; do
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP = $APP" >>"$DEPLOY_LOG"
          NODE_APP=$(echo "$APP" | tee -a "$DEPLOY_LOG" | cut -d ',' -f 1)
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_APP = $NODE_APP" >>"$DEPLOY_LOG"
          read -r NODE_INSTALL < <(eval "$USE_SUDO$APP_NPM" -g list | tee -a "$DEPLOY_LOG" | grep "$NODE_APP")
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_INSTALL = $NODE_INSTALL" >>"$DEPLOY_LOG"
          if [[ -n "$NODE_INSTALL" ]]; then
            printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\t%s$COL_CLR\n" "INSTALL" "$NODE_APP"
            printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Install $NODE_APP" >>"$DEPLOY_LOG"
            if ! eval "$USE_SUDO$APP_NPM" -g install "$NODE_APP" 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null; then
              printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "npm -g install $NODE_APP failed" >>"$DEPLOY_LOG"
              printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "npm -g install $NODE_APP failed"
              exit 255
            fi
          fi

          printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
          unset NODE_APP
          unset NODE_INSTALL
        done <"$FILE_NODE_APPS"

        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Updating checksum" >>"$DEPLOY_LOG"
        if [[ -z "$MD5_NODE" ]]; then
          echo "export MD5_NODE=$MD5_HASH" >>"$FILE_CHECKSUM"
        else
          sed -i '' "s/$MD5_NODE/$MD5_HASH/" "$FILE_CHECKSUM"
        fi

        unset MD5_HASH
        unset MD5
      fi
    fi

    printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\n" "OK"
  else
    if [[ -z $APP_NODE ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPING node not installed" >>"$DEPLOY_LOG"
      printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\t%s$COL_CLR\n" "SKIPPING" "node not installed"
      exit 255
    fi

    if [[ -z $APP_NPM ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPING  not installed" >>"$DEPLOY_LOG"
      printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\t%s$COL_CLR\n" "SKIPPING" "npm not installed"
      exit 255
    fi
  fi
else
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPING sudo required" >>"$DEPLOY_LOG"
  printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\t%s$COL_CLR\n" "SKIPPING" "sudo required"
fi

unset FILE_CHECKSUM
unset APP_NODE
unset APP_NPM
unset NEED_SUDO
unset USE_SUDO

STAGE="Verifying python3"
LOG_STAGE="PYTHON3"
printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
FILE_CHECKSUM=$HOME/.packages/checksum
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_CHECKSUM = $FILE_CHECKSUM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if $FILE_CHECKSUM exists"
} >>"$DEPLOY_LOG"
if [[ ! -f $FILE_CHECKSUM ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Create $FILE_CHECKSUM" >>"$DEPLOY_LOG"
  touch "$FILE_CHECKSUM"
fi

APP_PY3=$(which python3 | tee -a "$DEPLOY_LOG")
APP_PIP3=$(which pip3 | tee -a "$DEPLOY_LOG")
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_PY3 = $APP_PY3"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_PIP3 = $APP_PIP3"
} >>"$DEPLOY_LOG"
if [[ -x $APP_PY3 ]] && [[ -x $APP_PIP3 ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking for python3 outdated packages" >>"$DEPLOY_LOG"
  eval "$APP_PIP3" list --outdated --format freeze 2>&1 | tee -a "$DEPLOY_LOG" | while read -r LINE; do
    PYTHON_APP="${LINE/==/=}"
    {
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "LINE = $LINE"
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "PYTHON_APP = $PYTHON_APP"
    } >>"$DEPLOY_LOG"
    PYTHON_APP=$(echo "$PYTHON_APP" | tee -a "$DEPLOY_LOG" | cut -d '=' -f 1)
    {
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "PYTHON_APP = $PYTHON_APP"
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Update $PYTHON_APP"
    } >>"$DEPLOY_LOG"
    printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\t%s$COL_CLR\n" "UPDATE" "$PYTHON_APP"
    if ! eval "$APP_PIP3" install --upgrade "$PYTHON_APP" 2>&1 | tee -a "$DEPLOY_LOG" >/dev/null; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "pip3 install --upgrade $PYTHON_APP failed" >>"$DEPLOY_LOG"
      printf "$LINE_REM$COL_RED !  $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\t%s$COL_CLR\n" "ERROR" "pip3 install --upgrade $PYTHON_APP failed"
      exit 255
    fi

    unset PYTHON_APP
  done

  printf "$LINE_REM$COL_YLW - $COL_CLR$STAGE\t\t$COL_YLW%s$COL_CLR\n" "RUNNING"
  # shellcheck source=/dev/null
  source "$FILE_CHECKSUM"
  FILE_PYTHON_APPS=$HOME/.packages/python
  {
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_PYTHON_APPS = $FILE_PYTHON_APPS"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check if $FILE_PYTHON_APPS exists"
  } >>"$DEPLOY_LOG"
  if [[ -f $FILE_PYTHON_APPS ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Processing $FILE_PYTHON_APPS" >>"$DEPLOY_LOG"
    MD5=
    case "$DISPLAY_DEPLOY_OS" in
    "osx")
      MD5=$(which md5 | tee -a "$DEPLOY_LOG")
      MD5="$MD5 -r"
      ;;
    "ubuntu")
      MD5=$(which md5sum | tee -a "$DEPLOY_LOG")
      ;;
    esac
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5 = $MD5" >>"$DEPLOY_LOG"
    read -r MD5_HASH < <(eval "$MD5" "$FILE_PYTHON_APPS" | cut -d ' ' -f 1)
    {
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_HASH = $MD5_HASH"
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_PYTHON = $MD5_PYTHON"
    } >>"$DEPLOY_LOG"
    if [[ "$MD5_HASH" != "$MD5_PYTHON" ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "$FILE_PYTHON_APPS changed" >>"$DEPLOY_LOG"

      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Updating checksum" >>"$DEPLOY_LOG"
      if [[ -z "$MD5_PYTHON" ]]; then
        echo "export MD5_PYTHON=$MD5_HASH" >>"$FILE_CHECKSUM"
      else
        sed -i '' "s/$MD5_PYTHON/$MD5_HASH/" "$FILE_CHECKSUM"
      fi
    fi

    unset MD5_HASH
    unset MD5
  fi

  printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\n" "OK"
else
  if [[ -z $APP_PY3 ]]; then
    printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\t%s$COL_CLR\n" "SKIPPING" "python3 not installed"
    exit 255
  fi

  if [[ -z $APP_PIP3 ]]; then
    printf "$LINE_REM$COL_GRN:::$COL_CLR$STAGE\t\t$COL_GRN%s$COL_CLR\t%s$COL_CLR\n" "SKIPPING" "pip3 not installed"
    exit 255
  fi
fi

unset FILE_CHECKSUM
unset APP_PY3
unset APP_PIP3

LOG_STAGE="FINISH"
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_PUSH = $DOT_FILES_PUSH" >>"$DEPLOY_LOG"
if [[ $DOT_FILES_PUSH -gt 0 ]]; then
  STAGE="Verifying dot files"
  printf "$LINE_REM$COL_RED ! $COL_CLR$STAGE\t\t$COL_RED%s$COL_CLR\n" "PUSH"
else
  printf "$LINE_REM%s" ""
fi

unset DOT_FILES_PUSH
eval rm "$FILE_PID"
unset APP_SUDO
unset APP_GIT
unset FILE_PID
unset DISPLAY_DEPLOY_OS
unset USER_IS_SUDO
unset DISPLAY_DEPLOY_OS_UPPER

{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP = $APP"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_APT = $APP_APT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_BREW = $APP_BREW"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_GIT = $APP_GIT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_NODE = $APP_NODE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_NPM = $APP_NPM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_PY3 = $APP_PY3"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_PIP3 = $APP_PIP3"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_RUBY = $APP_RUBY"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_SUDO = $APP_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_APP = $BREW_APP"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_ARGS = $BREW_ARGS"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_CLEAN = $BREW_CLEAN"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_INSTALL = $BREW_INSTALL"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_UPDATES = $BREW_UPDATES"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "COLORTERM = $COLORTERM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DEFAULT_USER = $DEFAULT_USER"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DIR_DOT_FILES = $DIR_DOT_FILES"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DISABLE_AUTO_UPDATE = $DISABLE_AUTO_UPDATE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_CONFIGURE = $DOT_FILES_CONFIGURE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_PUSH = $DOT_FILES_PUSH"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_BREW_APPS = $FILE_BREW_APPS"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_CHECKSUM = $FILE_CHECKSUM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_ENV = $FILE_ENV"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DEPLOY_LOG = $DEPLOY_LOG"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_PID = $FILE_PID"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "ITERM2_SQUELCH_MARK = $ITERM2_SQUELCH_MARK"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "KEYTIMEOUT = $KEYTIMEOUT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5 = $MD5"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_BREW = $MD5_BREW"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_HASH = $MD5_HASH"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_NODE = $MD5_NODE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_PYTHON = $MD5_PYTHON"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NEED_SUDO = $NEED_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_APP = $NODE_APP"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DISPLAY_DEPLOY_OS = $DISPLAY_DEPLOY_OS"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DISPLAY_DEPLOY_OS_UPPER = $DISPLAY_DEPLOY_OS_UPPER"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_ID = $USER_ID"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_IS_ROOT = $USER_IS_ROOT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_IS_SUDO = $USER_IS_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USE_SUDO = $USE_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Update complete"
} >>"$DEPLOY_LOG"

unset STAGE
unset LOG_STAGE
unset DEPLOY_LOG