#!/usr/bin/env bash
COLOR_GREEN="\033[0;32m"
COLOR_NONE="\033[0m"
COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[0;33m"
FORMAT_REPLACE="\e[1A\e[K"
FILE_BUSY=$HOME/.update_in_progress

STAGE=":: Verifying environment"
if [[ -n $TMUX ]]; then
  printf "$COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t\t%s$COLOR_NONE\n" "TMUX"
  exit 0
fi

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  printf "$COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t\t%s$COLOR_NONE\n" "VSCODE"
  exit 0
fi

if [[ -f $FILE_BUSY ]]; then
  printf "$COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t\t%s$COLOR_NONE\n" "RUNNING"
  exit 0
fi
touch "$FILE_BUSY"

printf "$COLOR_NONE%s$COLOR_NONE\n" "$STAGE"
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
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "Unknown OS $OSTYPE"
  exit 255
fi

printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "SUDO"
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

printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "CONFIG"
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
printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "$OS_PREFIX_UPPER"
unset OS_PREFIX_UPPER

STAGE=":: Verifying config files"
printf "${NC}%s${NC}\n" "$STAGE"
printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "GIT"
APP_GIT=$(which git)
if [[ -z $APP_GIT ]]; then
  DOT_FILES_UPDATE=false
  DOT_FILES_INSTALL=false
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_GREEN%s$COLOR_NONE\t%s$COLOR_NONE\n" "SKIPPING" "git mising"
fi

printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\t%s$COLOR_NONE\n" "DOTFILES"
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
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALL"
  if ! eval "$GIT" clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules --quiet &>/dev/null; then
    printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git clone failed"
    exit 255
  fi

  DOT_FILES_CONFIGURE=true
  unset DOT_FILES_INSTALL
fi

if [[ $DOT_FILES_UPDATE == true ]]; then
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\n" "CHECKING"
  pushd "$DIR_DOT_FILES" &>/dev/null || return
  if ! read -r CURRENT_HEAD < <(eval "$APP_GIT" log --pretty=%H ...refs/heads/latest^); then
    printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git log failed"
    exit 255
  fi

  if ! read -r REMOTE_HEAD < <(eval "$APP_GIT" ls-remote origin -h refs/heads/latest | cut -f1); then
    printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git ls-remote failed"
    exit 255
  fi

  if [[ "$CURRENT_HEAD" != "$REMOTE_HEAD" ]]; then
    printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\n" "UPDATE"
    DOT_FILES_CONFIGURE=true
    if ! eval "$APP_GIT" pull --quiet &>/dev/null; then
      printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git pull failed"
      exit 255
    fi
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | wc -l); then
    printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "git status failed"
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

if [[ $DOT_FILES_CONFIGURE == true ]]; then
  pushd "$DIR_DOT_FILES" &>/dev/null || return
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\n" "CONFIGURE"
  DOT_FILES_INSTALLER=$HOME/.dotfiles/install
  if [[ ! -x "$DOT_FILES_INSTALLER" ]]; then
    printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install script missing"
    exit 255
  fi

  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_YELLOW%s$COLOR_NONE\n" "INSTALLER"
  if ! eval "$DOT_FILES_INSTALLER" &>/dev/null; then
    printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" "install script failed"
    exit 255
  fi

  if ! read -r DOT_FILES_PUSH < <(eval "$APP_GIT" status -s | wc -l); then
    printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\t%s$COLOR_NONE\n" "ERROR" " git status failed"
    exit 255
  fi

  popd &>/dev/null || return
  unset DOT_FILES_CONFIGURE
  unset DOT_FILES_INSTALLER
fi

if [[ $DOT_FILES_PUSH -gt 0 ]]; then
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_RED%s$COLOR_NONE\n" "PUSH"
else
  printf "$FORMAT_REPLACE$COLOR_NONE$STAGE\t$COLOR_GREEN%s$COLOR_NONE\n" "OK"
fi

unset DIR_DOT_FILES
unset DOT_FILES_PUSH
exit 0

SOURCES_APT=${HOME}/.packages/sources/apt
APPS_APT=${HOME}/.packages/apt
APP_APT_SRC=
APP_APT=
APP_BREW=
BREW_APPS=~/.brew_apps
DPKG_QUERY=
MD5=
MD5_APT_ADD_SRC=
NPM=
NODE=
NODE_APPS=~/.node_apps
PIP3=
PYTHON3=
PYTHON_APPS=~/.python_apps
REPLACE2="\e[2A\e[K"
RUBY=
ZSH=

STAGE=":: Verifying packages"
printf "${NC}%s${NC}\n" "$STAGE"
if [[ "$OS_PREFIX" == "OSX" ]]; then
  printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "CHECKING"
  BREW=$(which brew)
  if [[ -z $BREW ]]; then
    RUBY=$(which ruby)
    if [[ -f "$RUBY" ]]; then
      printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL" "brew"
      eval CI=1 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &>/dev/null
      if [[ $? != 0 ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "brew install failed"
      fi
    else
      printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING" "ruby missing"
    fi
  fi

  BREW=$(which brew)
  if [[ ! -z $BREW ]]; then
    printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "UPDATE"
    eval $BREW update &>/dev/null
    if [[ $? != 0 ]]; then
      printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "brew update failed"
      exit 255
    fi

    BREW_UPDATES=$($BREW outdated)
    if [[ $? != 0 ]]; then
      printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "brew outdated failed"
      exit 255
    fi

    if [[ ! -z "$BREW_UPDATES" ]]; then
      BREW_CLEAN=true
      printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "UPGRADE"
      eval $BREW upgrade &>/dev/null
      if [[ $? != 0 ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "brew upgrade failed"
        exit 255
      fi
    fi

    if [[ -f "$BREW_APPS" ]]; then
      MD5=$(which md5)
      MD5_HASH=$($MD5 -r "$BREW_APPS" | cut -d ' ' -f 1)
      if [[ "$MD5_HASH" != "$MD5_BREW_APPS" ]]; then
        BREW_CLEAN=true
        printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "PACKAGES"
        while read app; do
          BREW_ARGS=
          if [[ $app == *","* ]]; then
            BREW_APP=$(echo "$app" | cut -d ',' -f 1)
            BREW_ARGS="--$(echo "$app" | cut -d ',' -f 2)"
          fi

          BREW_INSTALL=$($BREW ls --versions $app)
          if [[ -z "$BREW_INSTALL" ]]; then
            printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL" $BREW_APP
            eval $BREW install $BREW_ARGS $BREW_APP &>/dev/null
          fi

          unset BREW_APP
          unset BREW_ARGS
          unset BREW_INSTALL
        done <"$BREW_APPS"

        if [[ -z "$MD5_BREW_APPS" ]]; then
          echo "export MD5_BREW_APPS=$MD5_HASH" >>$ENVIRONMENT
        else
          sed -i '' "s/$MD5_BREW_APPS/$MD5_HASH/" $ENVIRONMENT
        fi
      fi

      unset MD5
      unset MD5_HASH
    fi

    if [[ "$BREW_CLEAN" == true ]]; then
      printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "CLEANUP"
      eval $BREW cleanup &>/dev/null
      if [[ $? != 0 ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "brew cleanup failed"
        exit 255
      fi
    fi

    printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "OK"
  fi
fi

if [[ "$IS_SUDO" == true ]]; then
  if [[ "$OS_PREFIX" == "UBUNTU" ]]; then
    printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "CHECKING"
    APT_GET=$(which apt-get)
    if [[ ! -f "$APT_GET" ]]; then
      printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get missing"
      exit 255
    else
      eval $SUDO -E -n $APT_GET -qq update
      if [[ $? != 0 ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get update failed"
        exit 255
      fi

      APT_UPDATE=$($SUDO -E -n $APT_GET -qq upgrade --dry-run)
      if [[ $? != 0 ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get upgrade failed"
        exit 255
      fi

      if [[ ! -z "$APT_UPDATE" ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "UPGRADE"
        APT_CLEAN=true
        APT_UPGRADE=$($SUDO -E -n $APT_GET -qq upgrade -y)
        if [[ $? != 0 ]]; then
          printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get upgrade failed"
          exit 255
        fi

        unset APT_UPDATE
      fi

      APT_UPDATE=$($SUDO -E -n $APT_GET -qq dist-upgrade --dry-run)
      if [[ $? != 0 ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get dist-upgrade failed"
        exit 255
      fi

      if [[ ! -z "$APT_UPDATE" ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "DIST-UPGRADE"
        APT_CLEAN=true
        APT_UPGRADE=$($SUDO -E -n $APT_GET -qq dist-upgrade -y)
        if [[ $? != 0 ]]; then
          printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get dist-upgrade failed"
          exit 255
        fi

        unset APT_UPDATE
      fi

      if [[ -f "$APT_SOURCES" ]]; then
        MD5=$(which md5sum)
        APT_ADD_SRC=$(which add-apt-repository)
        printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "SOURCES"
        MD5_HASH=$($MD5 "$APT_SOURCES" | cut -d ' ' -f 1)
        if [[ "$MD5_HASH" != "$MD5_APT_ADD_SRC" ]]; then
          while read src; do
            printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "SOURCES" "$src"
            eval $SUDO $APT_ADD_SRC $src &>/dev/null
            if [[ $? != 0 ]]; then
              printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "$APT_ADD_SRC $src failed"
              exit 255
            fi
          done <"$APT_SOURCES"

          if [[ -z "$MD5_APT_ADD_SRC" ]]; then
            echo "export MD5_APT_ADD_SRC=$MD5_HASH" >>$ENVIRONMENT
          else
            sed -i "s/$MD5_APT_ADD_SRC/$MD5_HASH/" "$ENVIRONMENT"
          fi
        fi

        unset MD5
        unset MD5_HASH
      fi

      if [ -f "$APT_APPS" ]; then
        MD5=$(which md5sum)
        printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "PACKAGES"
        MD5_HASH=$($MD5 "$APT_APPS" | cut -d ' ' -f 1)
        DPKG_QUERY=$(which dpkg-query)
        if [[ "$MD5_HASH" != "$MD5_APT_APPS" ]]; then
          APT_CLEAN=true
          while read app; do
            APP_INSTALLED=$($DPKG_QUERY -W -f='${Status}' $app 2>/dev/null | grep -c "ok installed")
            APP_INSTALL=false
            if [[ $APP_INSTALLED == 0 ]]; then
              APP_INSTALL=true
            fi

            if [[ "$APP_INSTALL" == true ]]; then
              printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL" $app
              eval $SUDO $APT_GET -qq install $app &>/dev/null
              if [[ $? != 0 ]]; then
                printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get $app failed"
                exit 255
              fi
            fi

            unset APP_INSTALLED
          done <"$APT_APPS"

          if [[ -z "$MD5_APT_APPS" ]]; then
            echo "export MD5_APT_APPS=$MD5_HASH" >>$ENVIRONMENT
          else
            sed -i "s/$MD5_APT_APPS/$MD5_HASH/" "$ENVIRONMENT"
          fi
        fi

        unset MD5
        unset MD5_HASH
      fi

      if [[ "$APT_CLEAN" == true ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "CLEANUP"
        eval $SUDO -E -n $APT_GET -qq autoremove -y
        if [[ $? != 0 ]]; then
          printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get autoremove failed"
          exit 255
        fi

        eval $SUDO -E -n $APT_GET -qq autoclean -y
        if [[ $? != 0 ]]; then
          printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get autoclean failed"
          exit 255
        fi
      fi
    fi

    printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\n" "OK"
  fi
else
  printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING"
fi

STAGE=":: Verifying node"
printf "${NC}%s${NC}\n" "$STAGE"
printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "CHECKING"
NODE=$(which node)
if [[ ! -f "$NODE" ]]; then
  if [[ "$OS_PREFIX" == "OSX" ]]; then
    printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL"
    eval $BREW install node &>/dev/null
    if [[ $? != 0 ]]; then
      printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "nodejs failed"
      exit 255
    fi
  elif [[ "$OS_PREFIX" == "UBUNTU" ]] && [[ "$IS_SUDO" == true ]]; then
    APT_GET=$(which apt-get)
    printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL"
    eval $SUDO $APT_GET -qq install nodejs -y &>/dev/null
    if [[ $? != 0 ]]; then
      printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "nodejs failed"
      exit 255
    fi
  elif [[ "$IS_SUDO" == false ]]; then
    printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING"
  fi
fi

NODE=$(which node)
if [[ ! -z $NODE ]]; then
  NPM=$(which npm)
  if [[ -x "$NPM" ]]; then
    printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "PACKAGES"
    if [[ -f "$NODE_APPS" ]]; then
      if [[ "$OS_PREFIX" == "OSX" ]]; then
        MD5=$(which md5)
        MD5_HASH=$($MD5 -r "$NODE_APPS" | cut -d ' ' -f 1)
      elif [[ "$OS_PREFIX" == "UBUNTU" ]]; then
        MD5=$(which md5sum)
        MD5_HASH=$($MD5 "$NODE_APPS" | cut -d ' ' -f 1)
      fi

      if [[ "$MD5_HASH" != "$MD5_NODE_APPS" ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "PACKAGES"
        while read app; do
          printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "PACKAGES" $app
          NODE_APP=$($NPM install --quiet --upgrade $app &>/dev/null)
          if [[ $? != 0 ]]; then
            printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "npm $app failed"
            exit 255
          fi
          unset NODE_APP
        done <"$NODE_APPS"

        if [ -z "$MD5_NODE_APPS" ]; then
          echo "export MD5_NODE_APPS=$MD5_HASH" >>$ENVIRONMENT
        else
          sed -i '' "s/$MD5_NODE_APPS/$MD5_HASH/" $ENVIRONMENT
        fi
      fi

      unset MD5
      unset MD5_HASH
    fi

    printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "OK"
  else
    printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING" "npm missing"
  fi
fi

STAGE=":: Verifying python"
printf "${NC}%s${NC}\n" "$STAGE"
printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "CHECKING"
PYTHON3=$(which python3)
PIP3=$(which pip3)
if [[ ! -f "$PYTHON3" ]]; then
  if [[ "$OS_PREFIX" == "OSX" ]]; then
    printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL"
  elif [[ "$OS_PREFIX" == "UBUNTU" ]] && [[ "$IS_SUDO" == true ]]; then
    printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL"
  elif [[ "$IS_SUDO" == false ]]; then
    printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING"
  fi
else
  printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "OK"
fi

STAGE=":: Verifying default shell"
printf "${NC}%s${NC}\n" "$STAGE"
printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "CHECKING"
USER_SHELL=$(basename $SHELL)
if [ "$USER_SHELL" != "zsh" ]; then
  ZSH=$(which zsh)
  if [[ -z $ZSH ]]; then
    if [[ "$OS_PREFIX" == "OSX" ]]; then
      printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL"
      eval $BREW install zsh &>/dev/null
      if [[ $? != 0 ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "zsh install failed"
        exit 255
      fi
    elif [[ "$OS_PREFIX" == "UBUNTU" ]] && [[ "$IS_SUDO" == true ]]; then
      printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL"
      eval $SUDO $APT_GET -qq install zsh -y &>/dev/null
      if [[ $? != 0 ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "zsh install failed"
        exit 255
      fi
    elif [[ "$IS_SUDO" == false ]]; then
      printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING"
    fi
  fi

  ZSH=$(which zsh)
  if [[ ! -z $ZSH ]]; then
    if [[ "$IS_SUDO" == true ]]; then
      printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "UPDATE"
      eval $SUDO usermod --shell $ZSH $USER &>/dev/null
      if [ $? != 0 ]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "usermod failed"
        exit 255
      fi

      printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\t%s${NC}\n" "OK"
    else
      printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING"
    fi
  else
    printf "${REPLACE}${NC}${STAGE}\t${ERROR}%s${NC}\t%s${NC}\n" "MISSING" "zsh"
  fi
else
  printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\t%s${NC}\n" "OK"
fi

rm "$FILE_BUSY"
unset FILE_BUSY
