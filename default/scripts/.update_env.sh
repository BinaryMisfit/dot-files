#!/usr/bin/env bash

if [ -f ~/.update_in_progress ]; then
  exit 0
fi

touch ~/.update_in_progress

APT_ADD_SRC=
APT_APPS=~/.apt_apps
APT_GET=
APT_SOURCES=~/.apt_sources
BREW=
BREW_APPS=~/.brew_apps
CONFIGURE_DOT_FILES=false
DOT_FILES=~/.dotfiles
DOT_FILES_INSTALL=~/.dotfiles/install
DOT_FILES_PUSH=
DPKG_QUERY=
ENVIRONMENT=~/.environment.zsh
GIT=$(which git)
GREEN="\033[0;32m"
INSTALL_DOT_FILES=false
IS_SUDO=false
MD5=
MD5_APT_ADD_SRC=
NC="\033[0m"
NPM=
NODE=
NODE_APPS=~/.node_apps
OS_PREFIX=
PIP3=
PYTHON3=
PYTHON_APPS=~/.python_apps
RED="\033[0;31m"
REPLACE="\e[1A\e[K"
REPLACE2="\e[2A\e[K"
RUBY=
SUDO=$(which sudo)
UPDATE_DOT_FILES=true
YELLOW="\033[0;33m"
ZSH=

STAGE=":: Verifying environment"
printf "${NC}%s${NC}\n" "$STAGE"
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_PREFIX="OSX"
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  OS_PREFIX=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print toupper($1)}')
fi

if [[ -z $OS_PREFIX ]]; then
  printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "Unknown OS $OSTYPE"
  exit 255
fi

if [[ ! -d "$DOT_FILES" ]]; then
  UPDATE_DOT_FILES=false
  INSTALL_DOT_FILES=true
fi

if [[ ! -f "$ENVIRONMENT" ]]; then
  touch "$ENVIRONMENT"
fi

unset COLORTERM
unset DEFAULT_USER
unset ITERM2_SQUELCH_MARK
unset KEYTIMEOUT
unset MD5_BREW_APPS
source "$ENVIRONMENT"
if [[ -z $COLORTERM ]]; then
  echo "export COLORTERM=truecolor" >> $ENVIRONMENT
fi

if [[ -z $DEFAULT_USER ]]; then
  echo "export DEFAULT_USER=$(whoami)" >> $ENVIRONMENT
fi

if [[ -z $ITERM2_SQUELCH_MARK ]]; then
  echo "export ITERM2_SQUELCH_MARK=1" >> $ENVIRONMENT
fi

if [[ -z $KEYTIMEOUT ]]; then
  echo "export KEYTIMEOUT=1" >> $ENVIRONMENT
fi

if [[ -f "$SUDO" ]]; then
  if [[ "$OS_PREFIX" == "OSX" ]]; then
    IS_SUDO=$(groups $USER | grep -w admin)
  fi

  if [[ "$OS_PREFIX" == "UBUNTU" ]]; then
    IS_SUDO=$(groups $USER | grep -w sudo)
  fi

  if [[ "$IS_SUDO" != "" ]]; then
    IS_SUDO=true
  fi
fi

printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\n" "${OS_PREFIX}"
STAGE=":: Verifying config files"
printf "${NC}%s${NC}\n" "$STAGE"
if [[ -z "$GIT" ]]; then
  UPDATE_DOT_FILES=false
  INSTALL_DOT_FILES=false
  printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING" "git mising"
fi

if [[ "$INSTALL_DOT_FILES" == true ]]; then
  printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\n" "INSTALL"
  eval $GIT clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules --quiet &>/dev/null
  if [[ $? != 0 ]]; then
    printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git clone failed"
    exit 255
  fi

  CONFIGURE_DOT_FILES=true
fi

if [[ "$UPDATE_DOT_FILES" == true ]]; then
  printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "CHECKING"
  pushd $DOT_FILES &>/dev/null
  CURRENT_HEAD=$($GIT log --pretty=%H ...refs/heads/latest^)
  if [[ $? != 0 ]]; then
    printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git log failed"
    exit 255
  fi

  REMOTE_HEAD=$($GIT ls-remote origin -h refs/heads/latest | cut -f1)
  if [[ $? != 0 ]]; then
    printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git ls-remote failed"
    exit 255
  fi

  if [[ "$CURRENT_HEAD" != "$REMOTE_HEAD" ]]; then
    printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "UPDATE"
    CONFIGURE_DOT_FILES=true
    eval $GIT pull --quiet &>/dev/null
    if [[ $? != 0 ]]; then
      printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git pull failed"
      exit 255
    fi
  fi

  DOT_FILES_PUSH=$(eval $GIT status -s | wc -l)
  if [[ $? != 0 ]]; then
    printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git status failed"
    exit 255
  fi

  if [[ "$DOT_FILES_PUSH" -gt "0" ]]; then
    CONFIGURE_DOT_FILES=true
  fi

  popd &>/dev/null
fi

if [[ "$CONFIGURE_DOT_FILES" == true ]]; then
  printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "CONFIGURING"
  if [[ ! -f "$DOT_FILES_INSTALL" ]]; then
    printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "install script missing"
    exit 255
  fi

  eval $DOT_FILES_INSTALL &>/dev/null
  if [[ $? != 0 ]]; then
    printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "install failed"
    exit 255
  fi

  pushd $DOT_FILES &>/dev/null
  DOT_FILES_PUSH=$($GIT status -s | wc -l)
  if [[ $? != 0 ]]; then
    printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git status failed"
    exit 255
  fi

  popd &>/dev/null
fi

if [[ "$DOT_FILES_PUSH" -gt "0" ]]; then
  printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\n" "PUSH"
else
  printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\n" "OK"
fi

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
        printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "PACKAGES"
        while read app; do
          BREW_APP=$($BREW ls --versions $app)
          if [[ -z "$BREW_APP" ]]; then
            printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL" $app
            eval $BREW install $app &>/dev/null
          fi

          unset BREW_APP
        done < "$BREW_APPS"

        if [[ -z "$MD5_BREW_APPS" ]]; then
          echo "export MD5_BREW_APPS=$MD5_HASH" >> $ENVIRONMENT
        else
          sed -i '' "s/$MD5_BREW_APPS/$MD5_HASH/" $ENVIRONMENT
        fi
      fi

      unset MD5
      unset MD5_HASH
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
          done < "$APT_SOURCES"

          if [[ -z "$MD5_APT_ADD_SRC" ]]; then
            echo "export MD5_APT_ADD_SRC=$MD5_HASH" >> $ENVIRONMENT
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
          done < "$APT_APPS"

          echo "Update MD5"
          if [[ -z "$MD5_APT_APPS" ]]; then
            echo "export MD5_APT_APPS=$MD5_HASH" >> $ENVIRONMENT
          else
            sed -i "s/$MD5_APT_APPS/$MD5_HASH/" "$ENVIRONMENT"
          fi
        fi

        unset MD5
        unset MD5_HASH
      fi
    fi

    printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\n" "OK"
  fi
else
  printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING" "sudo required"
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
      printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "brew node failed"
      exit 255
    fi
  elif [[ "$OS_PREFIX" == "UBUNTU" ]] && [[ "$IS_SUDO" == true ]]; then
    APT_GET=$(which apt-get)
    printf "${REPLACE}${NC}${STAGE}\t\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL"
    eval $SUDO $APT_GET -qq install nodejs -y &>/dev/null
    if [[ $? != 0 ]]; then
      printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get nodejs failed"
      exit 255
    fi
  elif [[ "$IS_SUDO" == false ]]; then
    printf "${REPLACE}${NC}${STAGE}\t\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING" "sudo required"
  fi
fi

NODE=$(which node)
if [[ ! -z $"NODE" ]]; then
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
          NODE_APP=$($NPM -g install --quiet --upgrade $app &>/dev/null)
          if [[ $? != 0 ]]; then
            printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "npm $app failed"
            exit 255
          fi
          unset NODE_APP
        done < "$NODE_APPS"

        if [ -z "$MD5_NODE_APPS" ]; then
          echo "export MD5_NODE_APPS=$MD5_HASH" >> $ENVIRONMENT
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
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "brew install zsh failed"
        exit 255
      fi
    elif [[ "$OS_PREFIX" == "UBUNTU" ]] && [[ "$IS_SUDO" == true ]]; then
      printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "INSTALL"
      eval $SUDO $APT_GET -qq install zsh -y &>/dev/null
      if [[ $? != 0 ]]; then
        printf "${REPLACE}${NC}${STAGE}\t\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "apt-get install zsh failed"
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

unset APT_ADD_SRC
unset APT_APPS
unset APT_GET
unset APT_SOURCES
unset BREW
unset BREW_UPDATES
unset BREW_APPS
unset CONFIGURE_DOT_FILES
unset DOT_FILES
unset DOT_FILES_INSTALL
unset DOT_FILES_PUSH
unset DPKG_QUERY
unset ENVIRONMENT
unset GIT
unset GREEN
unset INSTALL_DOT_FILES
unset IS_SUDO
unset MD5
unset MD5_APT_ADD_SRC
unset NC
unset NPM
unset NODE
unset NODE_APPS
unset OS_PREFIX
unset PIP3
unset PYTHON3
unset PYTHON_APPS
unset RED
unset REPLACE
unset REPLACE2
unset RUBY
unset SUDO
unset USER_SHELL
unset UPDATE_DOT_FILES
unset YELLOW
unset ZSH

rm ~/.update_in_progress
