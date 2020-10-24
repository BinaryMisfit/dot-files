#!/usr/bin/env bash
COLOR_GREEN="\033[1;32m"
COLOR_NONE="\033[0m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
FORMAT_REPLACE="\e[1A\e[K"
FILE_BUSY=$HOME/.update_in_progress

STAGE="Verifying environment"
printf "$COLOR_YELLOW - $COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
if [[ -n $TMUX ]]; then
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "TMUX"
  exit 0
fi

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "VSCODE"
  exit 0
fi

if [[ -f $FILE_BUSY ]]; then
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "RUNNING"
  exit 0
fi
touch "$FILE_BUSY"

OS_PREFIX=
case "$OSTYPE" in
"darwin"*)
  OS_PREFIX='osx'
  ;;
"linux-gnu")
  OS_PREFIX=$(grep </etc/os-release "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
  ;;
esac
if [[ -z $OS_PREFIX ]]; then
  printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "$OSTYPE"
  exit 255
fi

printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "RUNNING"
APP_SUDO=$(which sudo)
USER_IS_ROOT=false
USER_IS_SUDO=false
USER_ID=$(id -u "$USER")
if [[ $USER_ID == 0 ]]; then
  USER_IS_ROOT=true
  USER_IS_SUDO=true
elif [[ -x $APP_SUDO ]]; then
  case "$OS_PREFIX" in
  "osx")
    USER_IS_SUDO=$(groups "$USER" | grep -w admin)
    ;;
  "ubuntu")
    USER_IS_SUDO=$(groups "$USER" | grep -w sudo)
    ;;
  esac

  if [[ "$USER_IS_SUDO" != "" ]]; then
    USER_IS_SUDO=true
  fi
fi

unset COLORTERM
unset DEFAULT_USER
unset DISABLE_AUTO_UPDATE
unset ITERM2_SQUELCH_MARK
unset KEYTIMEOUT
FILE_ENV=$HOME/.environment.zsh
if [[ ! -f $FILE_ENV ]]; then
  touch "$FILE_ENV"
fi

# shellcheck source=/dev/null
source "$FILE_ENV"
if [[ -z $COLORTERM ]]; then
  echo "export COLORTERM=truecolor" >>"$FILE_ENV"
fi

if [[ $USER_IS_ROOT == false ]] && [[ -z $DEFAULT_USER ]]; then
  echo "export DEFAULT_USER=$(whoami)" >>"$FILE_ENV"
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

# shellcheck source=/dev/null
source "$FILE_ENV"
unset FILE_ENV
unset USER_IS_ROOT

OS_PREFIX_UPPER=$(echo "$OS_PREFIX" | awk '{print toupper($1)}')
printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "$OS_PREFIX_UPPER"
unset OS_PREFIX_UPPER

STAGE="Verifying dot files"
printf "$COLOR_YELLOW - $COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "RUNNING"
APP_GIT=$(which git)
if [[ -z $APP_GIT ]]; then
  DOT_FILES_UPDATE=false
  DOT_FILES_INSTALL=false
  printf "$FORMAT_REPLACE$COLOR_GREEN:::$COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "git mising"
fi

DIR_DOT_FILES=$HOME/.dotfiles
DOT_FILES_CONFIGURE=false
DOT_FILES_INSTALL=false
DOT_FILES_UPDATE=false
if [[ -d $DIR_DOT_FILES ]]; then
  DOT_FILES_UPDATE=true
else
  DOT_FILES_INSTALL=true
fi

if [[ $DOT_FILES_INSTALL == true ]]; then
  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALL"
  if ! eval "$GIT" clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules --quiet &>/dev/null; then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git clone failed"
    exit 255
  fi

  DOT_FILES_CONFIGURE=true
  unset DOT_FILES_INSTALL
fi

printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
if [[ $DOT_FILES_UPDATE == true ]]; then
  pushd "$DIR_DOT_FILES" &>/dev/null || return
  read -r CURRENT_BRANCH < <(eval "$APP_GIT" branch | cut -d ' ' -f 2)
  if ! read -r CURRENT_HEAD < <(eval "$APP_GIT" log --pretty=%H ...refs/heads/"$CURRENT_BRANCH"^); then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git log failed"
    exit 255
  fi

  if ! read -r REMOTE_HEAD < <(eval "$APP_GIT" ls-remote origin -h refs/heads/"$CURRENT_BRANCH" | cut -f1); then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git ls-remote failed"
    exit 255
  fi

  if [[ "$CURRENT_HEAD" != "$REMOTE_HEAD" ]]; then
    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "UPDATE"
    DOT_FILES_CONFIGURE=true
    if ! eval "$APP_GIT" pull --quiet &>/dev/null; then
      printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git pull failed"
      exit 255
    fi
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | wc -l); then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git status failed"
    exit 255
  fi

  if [[ $DOT_FILES_PUSH -gt 0 ]]; then
    DOT_FILES_CONFIGURE=true
  fi

  popd &>/dev/null || return
  unset CURRENT_HEAD
  unset DOT_FILES_PUSH
  unset DOT_FILES_UPDATE
  unset REMOTE_HEAD
fi

printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
if [[ $DOT_FILES_CONFIGURE == true ]]; then
  pushd "$DIR_DOT_FILES" &>/dev/null || return
  DOT_FILES_INSTALLER=$HOME/.dotfiles/install
  if [[ ! -x "$DOT_FILES_INSTALLER" ]]; then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install script missing"
    exit 255
  fi

  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALLER"
  if ! eval "$DOT_FILES_INSTALLER" &>/dev/null; then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install script failed"
    exit 255
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | wc -l); then
    printf "$FORMAT_REPLACE$COLOR_RED ! $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" " git status failed"
    exit 255
  fi

  popd &>/dev/null || return
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
  APP_BREW=$(which brew)
  if [[ ! -x $APP_BREW ]]; then
    APP_RUBY=$(which ruby)
    if [[ -z $APP_RUBY ]]; then
      printf "$FORMAT_REPLACE$COLOR_GREEN::: $COLOR_NONE$STAGE\t\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "ruby missing"
      exit 255
    fi

    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALL"
    if ! eval CI=1 "$APP_RUBY" -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &>/dev/null; then
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install brew failed"
    fi

    unset APP_RUBY
  fi

  printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "RUNNING"
  APP_BREW=$(which brew)
  if ! eval "$APP_BREW" update &>/dev/null; then
    printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "brew update failed"
    exit 255
  fi

  read -r BREW_UPDATES < <(eval "$APP_BREW" outdated)
  if [[ -n "$BREW_UPDATES" ]]; then
    BREW_CLEAN=true
    printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\n" "UPGRADE"
    if ! eval "$APP_BREW" upgrade &>/dev/null; then
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
      MD5=$(which md5)
      MD5="$MD5 -r"
      ;;
    "ubuntu")
      MD5=$(which md5sum)
      ;;
    esac

    read -r MD5_HASH < <(eval "$MD5" "$FILE_BREW_APPS" | cut -d ' ' -f 1)
    if [[ "$MD5_HASH" != "$ND5_BREW" ]]; then
      BREW_CLEAN=true
      while IFS="" read -r APP || [ -n "$APP" ]; do
        BREW_APP=
        BREW_ARGS=
        BREW_APP=$(echo "$APP" | cut -d ',' -f 1)
        if [[ $APP == *","* ]]; then
          BREW_ARGS="--$(echo "$APP" | cut -d ',' -f 2)"
        fi

        read -r BREW_INSTALL < <("$APP_BREW" ls --versions "$BREW_APP")
        if [[ -z "$BREW_INSTALL" ]]; then
          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "INSTALL" "$BREW_APP"
          if ! eval "$APP_BREW" install "$BREW_ARGS" "$BREW_APP" &>/dev/null; then
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
    APP_SUDO=$(which sudo)
    if [[ ! -x $APP_SUDO ]]; then
      printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "sudo missing"
      exit 255
    fi

    APP_APT=$(which apt-get)
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

APP_NODE=$(which node)
APP_NPM=$(which npm)
NEED_SUDO=false
USE_SUDO=
if [[ "$OS_PREFIX" == "ubuntu" ]] && [[ $USER_IS_SUDO == true ]]; then
  USE_SUDO="$APP_SUDO -E -n "
elif [[ "$OS_PREFIX" == "ubuntu" ]]; then
  NEED_SUDO=true
fi

if [[ $NEED_SUDO == false ]]; then
  if [[ -x $APP_NODE ]] && [[ -x $APP_NPM ]]; then
    echo -e "$USE_SUDO\n\n"
    echo -e "$USE_SUDO$APP_NPM\n\n"
    read -r NODE_PATH < <(eval "$USE_SUDO$APP_NPM" -g root)
    echo -e "$NODE_PATH\n\n"
    eval "$USE_SUDO$APP_NPM" -g list --depth=0 --parseable
    eval "$USE_SUDO$APP_NPM" -g list --depth=0 --parseable | while read -r LINE; do
      if [[ ${#LINE} -gt ${#NODE_PATH} ]]; then
        NODE_APP=${LINE/$NODE_PATH/}
        if [[ -n "$NODE_APP" ]]; then
          NODE_APP=$(echo -e "$NODE_APP" | rev | cut -d '/' -f 1 | rev)
          printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "UPDATE" "$NODE_APP"
          eval "$USE_SUDO$APP_NPM" -g install --upgrade "$NODE_APP"
          if ! eval "$USE_SUDO$APP_NPM" -g install --upgrade "$NODE_APP" &>/dev/null; then
            printf "$FORMAT_REPLACE$COLOR_RED !  $COLOR_NONE$STAGE\t\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "npm -g install --upgrade $NODE_APP failed"
            exit 255
          fi

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
        MD5=$(which md5)
        MD5="$MD5 -r"
        ;;
      "ubuntu")
        MD5=$(which md5sum)
        ;;
      esac

      read -r MD5_HASH < <(eval "$MD5" "$FILE_NODE_APPS" | cut -d ' ' -f 1)
      if [[ "$MD5_HASH" != "$ND5_NODE" ]]; then
        while IFS="" read -r APP || [ -n "$APP" ]; do
          NODE_APP=
          NODE_APP=$(echo "$APP" | cut -d ',' -f 1)
          eval "$USE_SUDO$APP_NPM" -g list | grep "$NODE_APP"
          read -r NODE_INSTALL < <(eval "$USE_SUDO$APP_NPM" -g list | grep "$NODE_APP")
          if [[ -n "$NODE_INSTALL" ]]; then
            printf "$FORMAT_REPLACE$COLOR_YELLOW - $COLOR_NONE$STAGE\t\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "INSTALL" "$NODE_APP"
            eval "$USE_SUDO$APP_NPM" -g install "$NODE_APP"
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

APP_PY3=$(which python3)
APP_PIP3=$(which pip3)
if [[ -x $APP_PY3 ]] && [[ -x $APP_PIP3 ]]; then
  eval "$APP_PIP3" list --outdated --format freeze 2>/dev/null | while read -r LINE; do
    PYTHON_APP="${LINE/==/=}"
    PYTHON_APP=$(echo "$PYTHON_APP" | cut -d '=' -f 1)
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
      MD5=$(which md5)
      MD5="$MD5 -r"
      ;;
    "ubuntu")
      MD5=$(which md5sum)
      ;;
    esac

    read -r MD5_HASH < <(eval "$MD5" "$FILE_PYTHON_APPS" | cut -d ' ' -f 1)
    if [[ "$MD5_HASH" != "$ND5_PYTHON" ]]; then
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
