#!/usr/bin/env bash
COLOR_GREEN="\033[1;32m"
COLOR_NONE="\033[0m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
DIR_DOT_FILES=$HOME/.dotfiles
FORMAT_REPLACE="\e[1A\e[K"
FILE_BUSY=$HOME/.update_in_progress
FILE_LOG=$DIR_DOT_FILES/log/update_env.log

if [[ ! -f $FILE_LOG ]]; then
  touch "$FILE_LOG"
fi

{
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "STARTUP" "Update started"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "STARTUP" "DIR_DOT_FILES = ${DIR_DOT_FILES}"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "STARTUP" "FILE_BUSY = ${FILE_BUSY}"
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "STARTUP" "FILE_LOG = ${FILE_LOG}"
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
  echo "export DEFAULT_USER=$(whoami | tee "$FILE_LOG")" >>"$FILE_ENV"
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
unset USER_IS_ROOT

OS_PREFIX_UPPER=$(echo "$OS_PREFIX" | tee "$FILE_LOG" | awk '{print toupper($1)}')
printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "$OS_PREFIX_UPPER"
unset OS_PREFIX_UPPER

STAGE="Verifying dot files"
LOG_STAGE="DOTFILE"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "RUNNING"
APP_GIT=$(which git | tee "$FILE_LOG")
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
  printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "Installing $DIR_DOT_FILES" >>"$FILE_LOG"
  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALL"
  if ! eval "$GIT" clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules 2>&1 | tee "$FILE_LOG" >/dev/null; then
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
  pushd "$DIR_DOT_FILES" &>/dev/null || return
  read -r CURRENT_BRANCH < <(eval "$APP_GIT" branch | tee -a "$FILE_LOG" | cut -d ' ' -f 2)
  if ! read -r CURRENT_HEAD < <(eval "$APP_GIT" log --pretty=%H ...refs/heads/"$CURRENT_BRANCH"^ | tee "$FILE_LOG"); then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git log failed"
    exit 255
  fi

  if ! read -r REMOTE_HEAD < <(eval "$APP_GIT" ls-remote origin -h refs/heads/"$CURRENT_BRANCH" | tee "$FILE_LOG" | cut -f1); then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git ls-remote failed"
    exit 255
  fi

  {
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "CURRENT_BRANCH = $CURRENT_BRANCH"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "CURRENT_HEAD = $CURRENT_HEAD"
    printf "%s\t%s\t\t%s\n" "$(date +"%Y-%m-%dT%T")" "$LOG_STAGE" "REMOTE_HEAD = $REMOTE_HEAD"
  } >>"$FILE_LOG"
  if [[ "$CURRENT_HEAD" != "$REMOTE_HEAD" ]]; then
    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "UPDATE"
    DOT_FILES_CONFIGURE=true
    if ! eval "$APP_GIT" pull 2>&1 | tee "$FILE_LOG" >/dev/null; then
      printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git pull failed"
      exit 255
    fi
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | tee "$FILE_LOG" | wc -l); then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git status failed"
    exit 255
  fi

  if [[ $DOT_FILES_PUSH -gt 0 ]]; then
    DOT_FILES_CONFIGURE=true
  fi

  popd 2>&1 /dev/null || return
  unset CURRENT_HEAD
  unset DOT_FILES_PUSH
  unset DOT_FILES_UPDATE
  unset REMOTE_HEAD
fi

printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
if [[ $DOT_FILES_CONFIGURE == true ]]; then
  pushd "$DIR_DOT_FILES" /dev/null 2>&1 || return
  DOT_FILES_INSTALLER=$HOME/.dotfiles/install
  if [[ ! -x "$DOT_FILES_INSTALLER" ]]; then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install script missing"
    exit 255
  fi

  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALLER"
  if ! eval "$DOT_FILES_INSTALLER" 2>&1 | tee "$FILE_LOG" >/dev/null 2>&1; then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install script failed"
    exit 255
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | tee "$FILE_LOG" | wc -l); then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" " git status failed"
    exit 255
  fi

  popd 2>&1 /dev/null || return
  unset DOT_FILES_CONFIGURE
  unset DOT_FILES_INSTALLER
fi

if [[ $DOT_FILES_PUSH -gt 0 ]]; then
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\n" "PUSH"
else
  printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\n" "OK"
fi

unset DIR_DOT_FILES
unset DOT_FILES_PUSH

STAGE="Verifying packages"
printf "$COLOR_YELLOW:::$COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
case "$OS_PREFIX" in
"osx")
  APP_BREW=$(which brew | tee "$FILE_LOG")
  if [[ ! -x $APP_BREW ]]; then
    APP_RUBY=$(which ruby | tee "$FILE_LOG")
    if [[ -z $APP_RUBY ]]; then
      printf "$FORMAT_REPLACE$COLOR_GREEN::: $COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "ruby missing"
      exit 255
    fi

    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALL"
    if ! eval CI=1 "$APP_RUBY" -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" | tee "$FILE_LOG" /dev/null 2>&1; then
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install brew failed"
    fi

    unset APP_RUBY
  fi

  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
  APP_BREW=$(which brew | tee "$FILE_LOG")
  if ! eval "$APP_BREW" update | tee "$FILE_LOG" &>/dev/null; then
    printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "brew update failed"
    exit 255
  fi

  read -r BREW_UPDATES < <(eval "$APP_BREW" outdated | tee "$FILE_LOG")
  if [[ -n "$BREW_UPDATES" ]]; then
    BREW_CLEAN=true
    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "UPGRADE"
    if ! eval "$APP_BREW" upgrade &>/dev/null | tee "$FILE_LOG"; then
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "brew upgrade failed"
      exit 255
    fi
  fi

  unset BREW_UPDATES
  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
  FILE_CHECKSUM=$HOME/.packages/checksum
  if [[ ! -f $FILE_CHECKSUM ]]; then
    touch "$FILE_CHECKSUM"
  fi

  BREW_CLEAN=false
  # shellcheck source=/dev/null
  source "$FILE_CHECKSUM"
  FILE_BREW_APPS=$HOME/.packages/brew
  if [[ -f $FILE_BREW_APPS ]]; then
    MD5=
    case "$OS_PREFIX" in
    "osx")
      MD5=$(which md5 | tee "$FILE_LOG")
      MD5="$MD5 -r"
      ;;
    "ubuntu")
      MD5=$(which md5sum | tee "$FILE_LOG")
      ;;
    esac

    read -r MD5_HASH < <(eval "$MD5" "$FILE_BREW_APPS" | tee "$FILE_LOG" | cut -d ' ' -f 1)
    if [[ "$MD5_HASH" != "$MD5_BREW" ]]; then
      BREW_CLEAN=true
      while IFS="" read -r APP || [ -n "$APP" ]; do
        BREW_APP=
        BREW_ARGS=
        BREW_APP=$(echo "$APP" | tee "$FILE_LOG" | cut -d ',' -f 1)
        if [[ $APP == *","* ]]; then
          BREW_ARGS="--$(echo "$APP" | tee "$FILE_LOG" | cut -d ',' -f 2)"
        fi

        read -r BREW_INSTALL < <("$APP_BREW" ls --versions "$BREW_APP")
        if [[ -z "$BREW_INSTALL" ]]; then
          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "INSTALL" "$BREW_APP"
          if ! eval "$APP_BREW" install "$BREW_ARGS" "$BREW_APP" &>/dev/null | tee "$FILE_LOG"; then
            printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "brew install $BREW_APP failed"
            exit 255
          fi
        fi

        printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
        unset BREW_APP
        unset BREW_ARGS
        unset BREW_INSTALL
      done <"$FILE_BREW_APPS"
    fi

    if [[ -z "$MD5_BREW" ]]; then
      echo "export MD5_BREW=$MD5_HASH" >>"$FILE_CHECKSUM"
    else
      sed -i '' "s/$MD5_BREW/$MD5_HASH/" "$FILE_CHECKSUM"
    fi

    unset MD5_HASH
    unset MD5
  fi

  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
  if [[ $BREW_CLEAN == true ]]; then
    if ! eval "$APP_BREW" cleanup &>/dev/null; then
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
    APP_SUDO=$(which sudo | tee "$FILE_LOG")
    if [[ ! -x $APP_SUDO ]]; then
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "sudo missing"
      exit 255
    fi

    APP_APT=$(which apt-get | tee "$FILE_LOG")
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
printf "$COLOR_YELLOW:::$COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
FILE_CHECKSUM=$HOME/.packages/checksum
if [[ ! -f $FILE_CHECKSUM ]]; then
  touch "$FILE_CHECKSUM"
fi

APP_NODE=$(which node | tee "$FILE_LOG")
APP_NPM=$(which npm | tee "$FILE_LOG")
NEED_SUDO=false
USE_SUDO=
if [[ "$OS_PREFIX" == "ubuntu" ]] && [[ $USER_IS_SUDO == true ]]; then
  USE_SUDO="$APP_SUDO -E -n "
elif [[ "$OS_PREFIX" == "ubuntu" ]]; then
  NEED_SUDO=true
fi

if [[ $NEED_SUDO == false ]]; then
  if [[ -x $APP_NODE ]] && [[ -x $APP_NPM ]]; then
    read -r NODE_PATH < <(eval "$USE_SUDO$APP_NPM" -g root)
    eval "$USE_SUDO$APP_NPM" -g list outdated --depth=0 --parseable | while read -r LINE; do
      if [[ ${#LINE} -gt ${#NODE_PATH} ]]; then
        NODE_APP=${LINE/$NODE_PATH/}
        if [[ -n "$NODE_APP" ]]; then
          NODE_APP=$(echo -e "$NODE_APP" | tee "$FILE_LOG" | rev | cut -d '/' -f 1 | rev)
          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "UPDATE" "$NODE_APP"
          if ! eval "$USE_SUDO$APP_NPM" -g install --upgrade "$NODE_APP" &>/dev/null; then
            printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "npm -g install --upgrade $NODE_APP failed"
            exit 255
          fi

          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
          unset NODE_APP
        fi
      fi
    done

    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
    # shellcheck source=/dev/null
    source "$FILE_CHECKSUM"
    FILE_NODE_APPS=$HOME/.packages/node
    if [[ -f $FILE_NODE_APPS ]]; then
      MD5=
      case "$OS_PREFIX" in
      "osx")
        MD5=$(which md5 | tee "$FILE_LOG")
        MD5="$MD5 -r"
        ;;
      "ubuntu")
        MD5=$(which md5sum | tee "$FILE_LOG")
        ;;
      esac

      read -r MD5_HASH < <(eval "$MD5" "$FILE_NODE_APPS" | cut -d ' ' -f 1)
      if [[ "$MD5_HASH" != "$MD5_NODE" ]]; then
        while IFS="" read -r APP || [ -n "$APP" ]; do
          NODE_APP=$(echo "$APP" | tee "$FILE_LOG" | cut -d ',' -f 1)
          read -r NODE_INSTALL < <(eval "$USE_SUDO$APP_NPM" -g list | grep "$NODE_APP")
          if [[ -n "$NODE_INSTALL" ]]; then
            printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "INSTALL" "$NODE_APP"
            if ! eval "$USE_SUDO$APP_NPM" -g install "$NODE_APP" &>/dev/null; then
              printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "npm -g install $NODE_APP failed"
              exit 255
            fi
          fi

          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
          unset NODE_APP
          unset NODE_INSTALL
        done <"$FILE_NODE_APPS"

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
      printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "node not installed"
      exit 255
    fi

    if [[ -z $APP_NPM ]]; then
      printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "npm not installed"
      exit 255
    fi
  fi
else
  printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "sudo required"
fi

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

APP_PY3=$(which python3 | tee "$FILE_LOG")
APP_PIP3=$(which pip3 | tee "$FILE_LOG")
if [[ -x $APP_PY3 ]] && [[ -x $APP_PIP3 ]]; then
  eval "$APP_PIP3" list --outdated --format freeze 2>/dev/null | while read -r LINE; do
    PYTHON_APP="${LINE/==/=}"
    PYTHON_APP=$(echo "$PYTHON_APP" | tee "$FILE_LOG" | cut -d '=' -f 1)
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
      MD5=$(which md5 | tee "$FILE_LOG")
      MD5="$MD5 -r"
      ;;
    "ubuntu")
      MD5=$(which md5sum | tee "$FILE_LOG")
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

unset APP_PY3
unset APP_PIP3

eval rm "$FILE_BUSY"
unset FILE_BUSY
unset FILE_LOG
