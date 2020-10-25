#!/usr/bin/env bash
COLOR_GREEN="\033[1;32m"
COLOR_NONE="\033[0m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
DIR_DOT_FILES=$HOME/.dotfiles
FORMAT_REPLACE="\e[1A\e[K"
FILE_BUSY=$HOME/.update_in_progress
FILE_LOG=$DIR_DOT_FILES/log/update_env.log

if [[ ! -d $DIR_DOT_FILES ]]; then
  FILE_LOG="$HOME/.update_installer.log"
fi

if [[ ! -d $DIR_DOT_FILES/log ]]; then
  mkdir -p "$DIR_DOT_FILES/log"
fi

if [[ ! -f $FILE_LOG ]]; then
  touch "$FILE_LOG"
fi

LOG_STAGE="START"
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "STARTUP" "Update started"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_BREW = $APP_BREW"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_GIT = $APP_GIT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_RUBY = $APP_RUBY"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_SUDO = $APP_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "COLORTERM = $COLORTERM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DEFAULT_USER = $DEFAULT_USER"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DIR_DOT_FILES = $DIR_DOT_FILES"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DISABLE_AUTO_UPDATE = $DISABLE_AUTO_UPDATE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_CONFIGURE = $DOT_FILES_CONFIGURE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_PUSH = $DOT_FILES_PUSH"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_BUSY = $FILE_BUSY"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_ENV = $FILE_ENV"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_LOG = $FILE_LOG"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "ITERM2_SQUELCH_MARK = $ITERM2_SQUELCH_MARK"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "KEYTIMEOUT = $KEYTIMEOUT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "OS_PREFIX = $OS_PREFIX"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "OS_PREFIX_UPPER = $OS_PREFIX_UPPER"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_ID = $USER_ID"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_IS_ROOT = $USER_IS_ROOT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_IS_SUDO = $USER_IS_SUDO"
} >>"$FILE_LOG"
STAGE="Verifying environment"
LOG_STAGE="ENV"
printf "$COLOR_YELLOW - $COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if $FILE_BUSY exists"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "TMUX = $TMUX"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "TERM_PROGRAM = $TERM_PROGRAM"
} >>"$FILE_LOG"
if [[ -n $TMUX ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "TMUX Running" >>"$FILE_LOG"
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "TMUX"
  exit 0
fi

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "VSCode running" >>"$FILE_LOG"
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "VSCODE"
  exit 0
fi

if [[ -f $FILE_BUSY ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "Already running" >>"$FILE_LOG"
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "RUNNING"
  exit 0
fi
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Creating $FILE_BUSY" >>"$FILE_LOG"
touch "$FILE_BUSY"

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if current operating system is supported ($OSTYPE)" >>"$FILE_LOG"
OS_PREFIX=
case "$OSTYPE" in
"darwin"*)
  OS_PREFIX='osx'
  ;;
"linux-gnu")
  OS_PREFIX=$(grep </etc/os-release "PRETTY_NAME" | tee -a "$FILE_LOG" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
  ;;
esac
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Operating system is $OS_PREFIX" >>"$FILE_LOG"
if [[ -z $OS_PREFIX ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "Unsupported operating system ($OS_PREFIX)" >>"$FILE_LOG"
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "$OSTYPE"
  exit 255
fi

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if user can run sudo" >>"$FILE_LOG"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "RUNNING"
APP_SUDO=$(which sudo | tee -a "$FILE_LOG")
USER_IS_ROOT=false
USER_IS_SUDO=false
USER_ID=$(id -u "$USER" | tee -a "$FILE_LOG")
if [[ $USER_ID == 0 ]]; then
  USER_IS_ROOT=true
  USER_IS_SUDO=true
elif [[ -x $APP_SUDO ]]; then
  case "$OS_PREFIX" in
  "osx")
    USER_IS_SUDO=$(groups "$USER" | tee -a "$FILE_LOG" | grep -w admin)
    ;;
  "ubuntu")
    USER_IS_SUDO=$(groups "$USER" | tee -a "$FILE_LOG" | grep -w sudo)
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
} >>"$FILE_LOG"

unset COLORTERM
unset DEFAULT_USER
unset DISABLE_AUTO_UPDATE
unset ITERM2_SQUELCH_MARK
unset KEYTIMEOUT
if [[ ! -f $FILE_ENV ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Creating $FILE_ENV" >>"$FILE_LOG"
  touch "$FILE_ENV"
fi

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Sourcing $FILE_ENV" >>"$FILE_LOG"
# shellcheck source=/dev/null
source "$FILE_ENV"
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "COLORTERM = $COLORTERM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DEFAULT_USER = $DEFAULT_USER"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DISABLE_AUTO_UPDATE = $DISABLE_AUTO_UPDATE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "ITERM2_SQUELCH_MARK = $ITERM2_SQUELCH_MARK"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "KEYTIMEOUT = $KEYTIMEOUT"
} >>"$FILE_LOG"

if [[ -z $COLORTERM ]]; then
  echo "export COLORTERM=truecolor" >>"$FILE_ENV"
fi

if [[ $USER_IS_ROOT == false ]] && [[ -z $DEFAULT_USER ]]; then
  echo "export DEFAULT_USER=$(whoami | tee -a "$FILE_LOG")" >>"$FILE_ENV"
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

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Sourcing $FILE_ENV" >>"$FILE_LOG"
# shellcheck source=/dev/null
source "$FILE_ENV"
{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "COLORTERM = $COLORTERM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DEFAULT_USER = $DEFAULT_USER"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DISABLE_AUTO_UPDATE = $DISABLE_AUTO_UPDATE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "ITERM2_SQUELCH_MARK = $ITERM2_SQUELCH_MARK"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "KEYTIMEOUT = $KEYTIMEOUT"
} >>"$FILE_LOG"
unset FILE_ENV
unset USER_ID
unset USER_IS_ROOT

OS_PREFIX_UPPER=$(echo "$OS_PREFIX" | tee -a "$FILE_LOG" | awk '{print toupper($1)}')
printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "$OS_PREFIX_UPPER"
unset OS_PREFIX_UPPER

STAGE="Verifying dot files"
LOG_STAGE="DOTFILE"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "RUNNING"
APP_GIT=$(which git | tee -a "$FILE_LOG")
DOT_FILES_CONFIGURE=false
DOT_FILES_INSTALL=false
DOT_FILES_UPDATE=false
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DIR_DOT_FILES = $DIR_DOT_FILES" >>"$FILE_LOG"
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check if $DIR_DOT_FILES exists" >>"$FILE_LOG"
if [[ -d $DIR_DOT_FILES ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Update $DIR_DOT_FILES" >>"$FILE_LOG"
  DOT_FILES_UPDATE=true
else
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Install $DIR_DOT_FILES" >>"$FILE_LOG"
  DOT_FILES_INSTALL=true
fi

{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if git is installed"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_GIT = $APP_GIT"
} >>"$FILE_LOG"
if [[ -z $APP_GIT ]]; then
  DOT_FILES_UPDATE=false
  DOT_FILES_INSTALL=false
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPED: git not installed" >>"$FILE_LOG"
  printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "git mising"
fi

{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if git is installed"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_GIT = $APP_GIT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_CONFIGURE = $DOT_FILES_CONFIGURE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_INSTALL = $DOT_FILES_INSTALL"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_UPDATE = $DOT_FILES_UPDATE"
} >>"$FILE_LOG"
if [[ $DOT_FILES_INSTALL == true ]]; then
  echo -e "$DOT_FILES_INSTALL\n"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Installing $DIR_DOT_FILES" >>"$FILE_LOG"
  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALL"
  if ! eval "$APP_GIT" clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules 2>&1 | tee -a "$FILE_LOG" >/dev/null; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git clone failed" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git clone failed"
    exit 255
  fi

  DOT_FILES_CONFIGURE=true
  unset DOT_FILES_INSTALL
fi

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_CONFIGURE = $DOT_FILES_CONFIGURE" >>"$FILE_LOG"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
if [[ $DOT_FILES_UPDATE == true ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if $DIR_DOT_FILES needs updating" >>"$FILE_LOG"
  pushd "$DIR_DOT_FILES" >/dev/null || return
  read -r CURRENT_BRANCH < <(eval "$APP_GIT" branch | tee -a "$FILE_LOG" | cut -d ' ' -f 2)
  if ! read -r CURRENT_HEAD < <(eval "$APP_GIT" log --pretty=%H ...refs/heads/"$CURRENT_BRANCH"^ | tee -a "$FILE_LOG"); then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git log failed" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git log failed"
    exit 255
  fi

  if ! read -r REMOTE_HEAD < <(eval "$APP_GIT" ls-remote origin -h refs/heads/"$CURRENT_BRANCH" | tee -a "$FILE_LOG" | cut -f1); then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git ls-remote failed" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git ls-remote failed"
    exit 255
  fi

  {
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "CURRENT_BRANCH = $CURRENT_BRANCH"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "CURRENT_HEAD = $CURRENT_HEAD"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "REMOTE_HEAD = $REMOTE_HEAD"
  } >>"$FILE_LOG"
  if [[ "$CURRENT_HEAD" != "$REMOTE_HEAD" ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Updating $DIR_DOT_FILES" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "UPDATE"
    DOT_FILES_CONFIGURE=true
    if ! eval "$APP_GIT" pull 2>&1 | tee -a "$FILE_LOG" >/dev/null; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git pull failed" >>"$FILE_LOG"
      printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git pull failed"
      exit 255
    fi
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | tee -a "$FILE_LOG" | wc -l); then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "git status failed" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git status failed"
    exit 255
  fi

  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_PUSH = $DOT_FILES_PUSH" >>"$FILE_LOG"
  if [[ $DOT_FILES_PUSH -gt 0 ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Reconfigure $DIR_DOT_FILES due to local changes" >>"$FILE_LOG"
    DOT_FILES_CONFIGURE=true
  fi

  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_CONFIGURE = $DOT_FILES_CONFIGURE" >>"$FILE_LOG"
  popd >/dev/null || return
  unset CURRENT_HEAD
  unset DOT_FILES_PUSH
  unset DOT_FILES_UPDATE
  unset REMOTE_HEAD
fi

printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
if [[ $DOT_FILES_CONFIGURE == true ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Determining if installer can be run" >>"$FILE_LOG"
  pushd "$DIR_DOT_FILES" >/dev/null || return
  DOT_FILES_INSTALLER=$HOME/.dotfiles/install
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_INSTALLER = $DOT_FILES_INSTALLER" >>"$FILE_LOG"
  if [[ ! -x "$DOT_FILES_INSTALLER" ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "install script missing" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install script missing"
    exit 255
  fi

  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Running $DOT_FILES_INSTALLER" >>"$FILE_LOG"
  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALLER"
  if ! eval "$DOT_FILES_INSTALLER" 2>&1 | tee -a "$FILE_LOG" >/dev/null 2>&1; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "install script failed" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install script failed"
    exit 255
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | tee -a "$FILE_LOG" | wc -l); then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "status failed failed" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" " git status failed"
    exit 255
  fi

  popd >/dev/null || return
fi

printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_PUSH = $DOT_FILES_PUSH" >>"$FILE_LOG"
printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\n" "OK"

unset DIR_DOT_FILES
unset DOT_FILES_CONFIGURE
unset DOT_FILES_INSTALLER

STAGE="Verifying packages"
LOG_STAGE="PACKAGE"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
case "$OS_PREFIX" in
"osx")
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Processing operating system $OS_PREFIX" >>"$FILE_LOG"
  APP_BREW=$(which brew | tee -a "$FILE_LOG")
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_BREW = $APP_BREW" >>"$FILE_LOG"
  if [[ ! -x $APP_BREW ]]; then
    APP_RUBY=$(which ruby | tee -a "$FILE_LOG")
    if [[ -z $APP_RUBY ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPING ruby missing" >>"$FILE_LOG"
      printf "$FORMAT_REPLACE$COLOR_GREEN::: $COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "ruby missing"
      exit 255
    fi

    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Running $APP_RUBY" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALL"
    if ! eval CI=1 "$APP_RUBY" -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 2>&1 | tee -a "$FILE_LOG" >/dev/null; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "install brew failed" >>"$FILE_LOG"
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install brew failed"
    fi

    unset APP_RUBY
  fi

  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
  APP_BREW=$(which brew | tee -a "$FILE_LOG")
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_BREW = $APP_BREW" >>"$FILE_LOG"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Run $APP_BREW update" >>"$FILE_LOG"
  if ! eval "$APP_BREW" update 2>&1 | tee -a "$FILE_LOG" >/dev/null; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "brew update failed" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "brew update failed"
    exit 255
  fi

  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check for outdated packages" >>"$FILE_LOG"
  read -r BREW_UPDATES < <(eval "$APP_BREW" outdated 2>&1 | tee -a "$FILE_LOG" >/dev/null)
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_UPDATES = $BREW_UPDATES" >>"$FILE_LOG"
  if [[ -n "$BREW_UPDATES" ]]; then
    BREW_CLEAN=true
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Run $APP_BREW upgrade" >>"$FILE_LOG"
    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "UPGRADE"
    if ! eval "$APP_BREW" upgrade &>/dev/null | tee -a "$FILE_LOG"; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "brew upgrade failed" >>"$FILE_LOG"
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "brew upgrade failed"
      exit 255
    fi
  fi
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_CLEAN = $BREW_CLEAN" >>"$FILE_LOG"

  unset BREW_UPDATES
  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
  FILE_CHECKSUM=$HOME/.packages/checksum
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_CHECKSUM = $FILE_CHECKSUM" >>"$FILE_LOG"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check if $FILE_CHECKSUM exists" >>"$FILE_LOG"
  if [[ ! -f $FILE_CHECKSUM ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Create $FILE_CHECKSUM" >>"$FILE_LOG"
    touch "$FILE_CHECKSUM"
  fi

  {
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_CLEAN = $BREW_CLEAN" >>"$FILE_LOG"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Loading $FILE_CHECKSUM"
  } >>"$FILE_LOG"
  # shellcheck source=/dev/null
  source "$FILE_CHECKSUM"
  FILE_BREW_APPS=$HOME/.packages/brew
  {
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_BREW_APPS = $FILE_BREW_APPS"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check if $FILE_BREW_APPS exists"
  } >>"$FILE_LOG"
  if [[ -f $FILE_BREW_APPS ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Processing $FILE_BREW_APPS" >>"$FILE_LOG"
    MD5=
    case "$OS_PREFIX" in
    "osx")
      MD5=$(which md5 | tee -a "$FILE_LOG")
      MD5="$MD5 -r"
      ;;
    "ubuntu")
      MD5=$(which md5sum | tee -a "$FILE_LOG")
      ;;
    esac
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5 = $MD5" >>"$FILE_LOG"
    read -r MD5_HASH < <(eval "$MD5" "$FILE_BREW_APPS" | tee -a "$FILE_LOG" | cut -d ' ' -f 1)
    {
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_HASH = $MD5_HASH"
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_BREW = $MD5_BREW"
    } >>"$FILE_LOG"
    if [[ "$MD5_HASH" != "$MD5_BREW" ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "$FILE_BREW_APPS changed" >>"$FILE_LOG"
      BREW_CLEAN=true
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_CLEAN = $BREW_CLEAN" >>"$FILE_LOG"
      while IFS="" read -r APP || [ -n "$APP" ]; do
        BREW_APP=
        BREW_ARGS=
        BREW_APP=$(echo "$APP" | tee -a "$FILE_LOG" | cut -d ',' -f 1)
        if [[ $APP == *","* ]]; then
          BREW_ARGS="--$(echo "$APP" | tee -a "$FILE_LOG" | cut -d ',' -f 2)"
        fi

        read -r BREW_INSTALL < <("$APP_BREW" ls --versions "$BREW_APP")
        {
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP = $APP"
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_APP = $BREW_APP"
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_ARGS = $BREW_ARGS"
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "BREW_INSTALL = $BREW_INSTALL"
        } >>"$FILE_LOG"
        if [[ -z "$BREW_INSTALL" ]]; then
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Installing $BREW_APP" >>"$FILE_LOG"
          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "INSTALL" "$BREW_APP"
          if ! eval "$APP_BREW" install "$BREW_ARGS" "$BREW_APP" 2>&1 | tee -a "$FILE_LOG" >/dev/null; then
            printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "brew install $BREW_APP failed" >>"$FILE_LOG"
            printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "brew install $BREW_APP failed"
            exit 255
          fi
        fi

        printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
        unset BREW_APP
        unset BREW_ARGS
        unset BREW_INSTALL
      done <"$FILE_BREW_APPS"

      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Updating checksum" >>"$FILE_LOG"
      if [[ -z "$MD5_BREW" ]]; then
        echo "export MD5_BREW=$MD5_HASH" >>"$FILE_CHECKSUM"
      else
        sed -i '' "s/$MD5_BREW/$MD5_HASH/" "$FILE_CHECKSUM"
      fi
    fi
  fi

  unset MD5_HASH
  unset MD5
  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
  if [[ $BREW_CLEAN == true ]]; then
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Running $APP_BREW cleanup" >>"$FILE_LOG"
    if ! eval "$APP_BREW" cleanup 2>&1 | tee "$FILE_LOG" >/dev/null; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "brew cleanup failed" >>"$FILE_LOG"
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "brew cleanup failed"
      exit 255
    fi
  fi

  printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\n" "OK"
  unset BREW_CLEAN
  unset FILE_CHECKSUM
  unset FILE_BREW_APPS
  unset APP_BREW
  ;;
"ubuntu")
  if [[ $USER_IS_SUDO == false ]]; then
    printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "sudo required"
  else
    APP_SUDO=$(which sudo | tee -a "$FILE_LOG")
    if [[ ! -x $APP_SUDO ]]; then
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "sudo missing"
      exit 255
    fi

    APP_APT=$(which apt-get | tee -a "$FILE_LOG")
    if [[ ! -x $APP_APT ]]; then
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "apt-get missing"
      exit 255
    fi

    if ! eval "$APP_SUDO" -E -n "$APP_APT" -qq update; then
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "apt-get update failed"
      exit 255
    fi

    read -r APT_UPDATE < <(eval "$APP_SUDO" -E -n "$APP_APT" -qq upgrade --dry-run)
    if [[ -n $APT_UPDATE ]]; then
      APT_CLEAN=true
      if ! eval "$APP_SUDO" -E -n "$APP_APT" -qq upgrade -y &>/dev/null; then
        printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "apt-get upgrade failed"
        exit 255
      fi

      unset APT_UPDATE
      read -r APT_UPDATE < <(eval "$APP_SUDO" -E -n "$APP_APT" -qq dist-upgrade --dry-run)
      if [[ -n $APT_UPDATE ]]; then
        APT_CLEAN=true
        if ! eval "$APP_SUDO" -E -n "$APP_APT" -qq dist-upgrade -y &>/dev/null; then
          printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "apt-get dist-upgrade failed"
          exit 255
        fi

        unset APT_UPDATE
      fi

      if [[ $APT_CLEAN == true ]]; then
        if eval "$APP_SUDO" -E -n "$APP_APT" -qq autoremove -y &>/dev/null; then
          printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "apt-get autoremove failed"
          exit 255
        fi

        if eval "$APP_SUDO" -E -n "$APP_APT" -qq autoclean -y &>/dev/null; then
          printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "apt-get autoremove failed"
          exit 255
        fi
      fi

      unset APT_CLEAN
      unset APP_APT
      unset APP_SUDO
    fi

    printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\n" "OK"
  fi
  ;;
esac

STAGE="Verifying node"
LOG_STAGE="NODE"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
FILE_CHECKSUM=$HOME/.packages/checksum
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_CHECKSUM = $FILE_CHECKSUM" >>"$FILE_LOG"
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking if $FILE_CHECKSUM exists" >>"$FILE_LOG"
if [[ ! -f $FILE_CHECKSUM ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Creating $FILE_CHECKSUM" >>"$FILE_LOG"
  touch "$FILE_CHECKSUM"
fi

APP_NODE=$(which node | tee -a "$FILE_LOG")
APP_NPM=$(which npm | tee -a "$FILE_LOG")
NEED_SUDO=false
USE_SUDO=
if [[ "$OS_PREFIX" == "ubuntu" ]] && [[ $USER_IS_SUDO == true ]]; then
  USE_SUDO="$APP_SUDO -E -n "
elif [[ "$OS_PREFIX" == "ubuntu" ]]; then
  NEED_SUDO=true
fi

{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_NODE = $APP_NODE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_NPM = $APP_NPM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NEED_SUDO = $NEED_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USE_SUDO = $USE_SUDO"
} >>"$FILE_LOG"
if [[ $NEED_SUDO == false ]]; then
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Node does not require sudo or sudo enabled" >>"$FILE_LOG"
  if [[ -x $APP_NODE ]] && [[ -x $APP_NPM ]]; then
    read -r NODE_PATH < <(eval "$USE_SUDO$APP_NPM" -g root | tee "$FILE_LOG")
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_PATH = $NODE_PATH" >>"$FILE_LOG"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Checking for node outdated packages" >>"$FILE_LOG"
    eval "$USE_SUDO$APP_NPM" -g list outdated --depth=0 --parseable | tee "$FILE_LOG" | while read -r LINE; do
      {
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "LINE = $LINE"
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "LINE LENGTH = ${#LINE}"
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_PATH LENGTH = ${#NODE_PATH}"
      } >>"$FILE_LOG"
      if [[ ${#LINE} -gt ${#NODE_PATH} ]]; then
        NODE_APP=${LINE/$NODE_PATH/}
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_APP = $NODE_APP" >>"$FILE_LOG"
        if [[ -n "$NODE_APP" ]]; then
          NODE_APP=$(echo -e "$NODE_APP" | tee -a "$FILE_LOG" | rev | cut -d '/' -f 1 | rev)
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Update $NODE_APP" >>"$FILE_LOG"
          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "UPDATE" "$NODE_APP"
          if ! eval "$USE_SUDO$APP_NPM" -g install --upgrade "$NODE_APP" 2>&1 | tee "$FILE_LOG" >/dev/null; then
            printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "npm -g install --upgrade $NODE_APP failed" >>"$FILE_LOG"
            printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "npm -g install --upgrade $NODE_APP failed"
            exit 255
          fi

          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
          unset NODE_APP
        fi
      fi
    done

    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Loading $FILE_CHECKSUM" >>"$FILE_LOG"
    # shellcheck source=/dev/null
    source "$FILE_CHECKSUM"
    FILE_NODE_APPS=$HOME/.packages/node
    {
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_NODE_APPS = $FILE_NODE_APPS"
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Check if $FILE_NODE_APPS exists"
    } >>"$FILE_LOG"
    if [[ -f $FILE_NODE_APPS ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Processing $FILE_NODE_APPS" >>"$FILE_LOG"
      MD5=
      case "$OS_PREFIX" in
      "osx")
        MD5=$(which md5 | tee -a "$FILE_LOG")
        MD5="$MD5 -r"
        ;;
      "ubuntu")
        MD5=$(which md5sum | tee -a "$FILE_LOG")
        ;;
      esac
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5 = $MD5" >>"$FILE_LOG"
      read -r MD5_HASH < <(eval "$MD5" "$FILE_NODE_APPS" | cut -d ' ' -f 1)
      {
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_HASH = $MD5_HASH"
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_NODE = $MD5_NODE"
      } >>"$FILE_LOG"
      if [[ "$MD5_HASH" != "$MD5_NODE" ]]; then
        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "$FILE_NODE_APPS changed" >>"$FILE_LOG"
        while IFS="" read -r APP || [ -n "$APP" ]; do
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP = $APP" >>"$FILE_LOG"
          NODE_APP=$(echo "$APP" | tee -a "$FILE_LOG" | cut -d ',' -f 1)
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_APP = $NODE_APP" >>"$FILE_LOG"
          read -r NODE_INSTALL < <(eval "$USE_SUDO$APP_NPM" -g list | tee "$FILE_LOG" | grep "$NODE_APP")
          printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_INSTALL = $NODE_INSTALL" >>"$FILE_LOG"
          if [[ -n "$NODE_INSTALL" ]]; then
            printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "INSTALL" "$NODE_APP"
            printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Install $NODE_APP" >>"$FILE_LOG"
            if ! eval "$USE_SUDO$APP_NPM" -g install "$NODE_APP" 2>&1 | tee "$FILE_LOG" >/dev/null; then
              printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "ERROR" "npm -g install $NODE_APP failed" >>"$FILE_LOG"
              printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "npm -g install $NODE_APP failed"
              exit 255
            fi
          fi

          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
          unset NODE_APP
          unset NODE_INSTALL
        done <"$FILE_NODE_APPS"

        printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Updating checksum" >>"$FILE_LOG"
        if [[ -z "$MD5_NODE" ]]; then
          echo "export MD5_NODE=$MD5_HASH" >>"$FILE_CHECKSUM"
        else
          sed -i '' "s/$MD5_NODE/$MD5_HASH/" "$FILE_CHECKSUM"
        fi

        unset MD5_HASH
        unset MD5
      fi
    fi

    printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\n" "OK"
  else
    if [[ -z $APP_NODE ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPING node not installed" >>"$FILE_LOG"
      printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "node not installed"
      exit 255
    fi

    if [[ -z $APP_NPM ]]; then
      printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPING  not installed" >>"$FILE_LOG"
      printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "npm not installed"
      exit 255
    fi
  fi
else
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "SKIPPING sudo required" >>"$FILE_LOG"
  printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "sudo required"
fi

unset FILE_CHECKSUM
unset APP_NODE
unset APP_NPM
unset NEED_SUDO
unset USE_SUDO

STAGE="Verifying python3"
printf "$COLOR_YELLOW:::$COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
FILE_CHECKSUM=$HOME/.packages/checksum
if [[ ! -f $FILE_CHECKSUM ]]; then
  touch "$FILE_CHECKSUM"
fi

APP_PY3=$(which python3 | tee -a "$FILE_LOG")
APP_PIP3=$(which pip3 | tee -a "$FILE_LOG")
if [[ -x $APP_PY3 ]] && [[ -x $APP_PIP3 ]]; then
  eval "$APP_PIP3" list --outdated --format freeze 2>/dev/null | while read -r LINE; do
    PYTHON_APP="${LINE/==/=}"
    PYTHON_APP=$(echo "$PYTHON_APP" | tee -a "$FILE_LOG" | cut -d '=' -f 1)
    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "UPDATE" "$PYTHON_APP"
    if ! eval "$APP_PIP3" install --upgrade "$PYTHON_APP" &>/dev/null; then
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "pip3 install --upgrade $PYTHON_APP failed"
      exit 255
    fi

    unset PYTHON_APP
  done

  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
  # shellcheck source=/dev/null
  source "$FILE_CHECKSUM"
  FILE_PYTHON_APPS=$HOME/.packages/python
  if [[ -f $FILE_PYTHON_APPS ]]; then
    MD5=
    case "$OS_PREFIX" in
    "osx")
      MD5=$(which md5 | tee -a "$FILE_LOG")
      MD5="$MD5 -r"
      ;;
    "ubuntu")
      MD5=$(which md5sum | tee -a "$FILE_LOG")
      ;;
    esac

    read -r MD5_HASH < <(eval "$MD5" "$FILE_PYTHON_APPS" | cut -d ' ' -f 1)
    if [[ "$MD5_HASH" != "$MD5_PYTHON" ]]; then
      if [[ -z "$MD5_PYTHON" ]]; then
        echo "export MD5_PYTHON=$MD5_HASH" >>"$FILE_CHECKSUM"
      else
        sed -i '' "s/$MD5_PYTHON/$MD5_HASH/" "$FILE_CHECKSUM"
      fi

      unset MD5_HASH
      unset MD5
    fi
  fi

  printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\n" "OK"
else
  if [[ -z $APP_PY3 ]]; then
    printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "python3 not installed"
    exit 255
  fi

  if [[ -z $APP_PIP3 ]]; then
    printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "pip3 not installed"
    exit 255
  fi
fi

unset FILE_CHECKSUM
unset APP_PY3
unset APP_PIP3

LOG_STAGE="FINISH"
printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "DOT_FILES_PUSH = $DOT_FILES_PUSH" >>"$FILE_LOG"
if [[ $DOT_FILES_PUSH -gt 0 ]]; then
  STAGE="Verifying dot files"
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\n" "PUSH"
else
  printf "$FORMAT_REPLACE%s" ""
fi

unset DOT_FILES_PUSH
eval rm "$FILE_BUSY"
unset APP_SUDO
unset APP_GIT
unset FILE_BUSY
unset OS_PREFIX
unset USER_IS_SUDO

{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP = $APP"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_APT = $APP_APT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_BREW = $APP_BREW"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_GIT = $APP_GIT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_NODE = $APP_NODE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "APP_NPM = $APP_NPM"
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
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_BUSY = $FILE_BUSY"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_CHECKSUM = $FILE_CHECKSUM"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_ENV = $FILE_ENV"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "FILE_LOG = $FILE_LOG"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "ITERM2_SQUELCH_MARK = $ITERM2_SQUELCH_MARK"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "KEYTIMEOUT = $KEYTIMEOUT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5 = $MD5"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_BREW = $MD5_BREW"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_HASH = $MD5_HASH"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "MD5_NODE = $MD5_NODE"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NEED_SUDO = $NEED_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "NODE_APP = $NODE_APP"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "OS_PREFIX = $OS_PREFIX"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "OS_PREFIX_UPPER = $OS_PREFIX_UPPER"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_ID = $USER_ID"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_IS_ROOT = $USER_IS_ROOT"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USER_IS_SUDO = $USER_IS_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "USE_SUDO = $USE_SUDO"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Update complete"
} >>"$FILE_LOG"

unset STAGE
unset LOG_STAGE
unset FILE_LOG
