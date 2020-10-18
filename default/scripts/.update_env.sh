#!/usr/bin/env bash

if [ -f ~/.update_in_progress ]; then
  exit 0
fi

touch ~/.update_in_progress

BREW=$(which brew)
CONFIGURE_DOT_FILES=false
DOT_FILES=~/.dotfiles
DOT_FILES_INSTALL=~/.dotfiles/install
DOT_FILES_PUSH=
ENVIRONMENT=~/.environment.zsh
GIT=$(which git)
GREEN="\033[0;32m"
INSTALL_DOT_FILES=false
NC="\033[0m"
NPM=$(which npm)
OS_PREFIX=
PIP3=$(which pip3)
RED="\033[0;31m"
REPLACE="\e[1A\e[K"
REPLACE2="\e[2A\e[K"
UPDATE_DOT_FILES=true
YELLOW="\033[0;33m"

STAGE=":: Verifying environment"
printf "${NC}%s${NC}\n" "$STAGE"
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_PREFIX="osx"
elif [ "$OSTYPE" == "linux-gnu" ]; then
  OS_PREFIX=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
fi

if [ -z $OS_PREFIX ]; then
  printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "Unknown OS $OSTYPE"
  exit 255
fi

if [ ! -d "$DOT_FILES" ]; then
  UPDATE_DOT_FILES=false
  INSTALL_DOT_FILES=true
fi

if [ ! -f "$ENVIRONMENT" ]; then
  touch "$ENVIRONMENT"
fi

unset COLORTERM
unset DEFAULT_USER
unset ITERM2_SQUELCH_MARK
unset KEYTIMEOUT
unset MD5_BREW_APPS
source "$ENVIRONMENT"
if [ -z $COLORTERM ]; then
  echo "export COLORTERM=truecolor" >> $ENVIRONMENT
fi
if [ -z $DEFAULT_USER ]; then
  echo "export DEFAULT_USER=$(whoami)" >> $ENVIRONMENT
fi
if [ -z $ITERM2_SQUELCH_MARK ]; then
  echo "export ITERM2_SQUELCH_MARK=1" >> $ENVIRONMENT
fi
if [ -z $KEYTIMEOUT ]; then
  echo "export KEYTIMEOUT=1" >> $ENVIRONMENT
fi
printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\n" "${OS_PREFIX}"

STAGE=":: Verifying config files"
printf "${NC}%s${NC}\n" "$STAGE"
if [ -z "$GIT" ]; then
  UPDATE_DOT_FILES=false
  INSTALL_DOT_FILES=false
  printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "SKIPPING" "``git`` not found"
fi

if [ "$INSTALL_DOT_FILES" == true ]; then
  printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\n" "INSTALLING"
  eval $GIT clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules --quiet &>/dev/null
  if [ $? != 0 ]; then
    printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git clone failed"
    exit 255
  fi
  CONFIGURE_DOT_FILES=true
fi

if [ "$UPDATE_DOT_FILES" == true ]; then
  printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "CHECKING"
  pushd $DOT_FILES &>/dev/null
  CURRENT_HEAD=$(eval $GIT log --pretty=%H ...refs/heads/latest^)
  if [ $? != 0 ]; then
    printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git log failed"
    exit 255
  fi
  REMOTE_HEAD=$(eval $GIT ls-remote origin -h refs/heads/latest | cut -f1)
  if [ $? != 0 ]; then
    printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git ls-remote failed"
    exit 255
  fi
  if [ "$CURRENT_HEAD" != "$REMOTE_HEAD" ]; then
    printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "UPDATE"
    CONFIGURE_DOT_FILES=true
    eval $GIT pull --quiet &>/dev/null
    if [ $? != 0 ]; then
      printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git pull failed"
      exit 255
    fi
  fi
  DOT_FILES_PUSH=$(eval $GIT status -s | wc -l)
  if [ $? != 0 ]; then
    printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git status failed"
    exit 255
  fi
  if [ "$DOT_FILES_PUSH" -gt "0" ]; then
    CONFIGURE_DOT_FILES=true
  fi
  popd &>/dev/null
fi

if [ "$CONFIGURE_DOT_FILES" == true ]; then
  printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\t%s${NC}\n" "CONFIGURING"
  if [ ! -f "$DOT_FILES_INSTALL" ]; then
    printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "install script missing"
    exit 255
  fi
  eval $DOT_FILES_INSTALL &>/dev/null
  if [ $? != 0 ]; then
    printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "install failed"
    exit 255
  fi
  pushd $DOT_FILES &>/dev/null
  DOT_FILES_PUSH=$(eval $GIT status -s | wc -l)
  if [ $? != 0 ]; then
    printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git status failed"
    exit 255
  fi
  popd &>/dev/null
fi
if [ "$DOT_FILES_PUSH" -gt "0" ]; then
  printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\n" "PUSH"
else
  printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\n" "OK"
fi

if [ "$OS_PREFIX" == "osx" ]; then
  echo ":: Verifying ``brew``"
  if [ -z $BREW ]; then
    echo " :: Installing ``brew``"
    CI=1 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &>/dev/null
    if [ $? != 0 ]; then
      echo " :: ERROR: ``brew`` installation failed"
      exit 255
    fi
  else
    echo " :: Updating ``brew``"
    eval $BREW update &>/dev/null
    if [ $? != 0 ]; then
      echo " :: ERROR: ``brew`` update failed"
      exit 255
    fi
    BREW_UPDATES=$(eval $BREW outdated)
    echo " :: Verifying ``brew`` packages"
    if [ $? != 0 ]; then
      echo " :: ERROR: ``brew`` outdated failed"
      exit 255
    fi
    if [ ! -z "$BREW_UPDATES" ]; then
      echo " :: Upgrading ``brew`` packages"
      eval $BREW upgrade &>/dev/null
      if [ $? != 0 ]; then
        echo " :: ERROR: ``brew`` upgrade failed"
        exit 255
      fi
    fi
  fi
  if [ -f ~/.brew_apps ]; then
    echo " :: Verifying ``brew`` required packages"
    MD5_HASH=$(md5 -r ~/.brew_apps | cut -d ' ' -f 1)
    if [[ "$MD5_HASH" != "$MD5_BREW_APPS" ]]; then
      echo " :: Installing ``brew`` required packages"
      if [ -z "$MD5_BREW_APPS" ]; then
        echo "export MD5_BREW_APPS=$MD5_HASH" >> $ENVIRONMENT
      else
        sed -i '' "s/$MD5_BREW_APPS/$MD5_HASH/" $ENVIRONMENT
      fi
      while read app; do
        BREW_APP=$(eval $BREW ls --versions $app)
        if [ -z "$BREW_APP" ]; then
          eval $BREW install $app &>/dev/null
        fi
        unset BREW_APP
      done < ~/.brew_apps
    fi
    unset MD5_HASH
  fi
fi

if [ "$OS_PREFIX" == "ubuntu" ]; then
  echo ":: Verifying ``apt-get``"
  APT_UPDATE=$(sudo apt-get -qq upgrade --dry-run)
  if [ $? != 0 ]; then
    echo " :: ERROR: ``apt-get`` upgrade failed"
    exit 255
  fi
  if [ ! -z "$APT_UPDATE" ]; then
    echo " :: Updating ``apt-get`` packages"
    APT_UPGRADE=$(sudo apt-get -qq upgrade -y)
    if [ $? != 0 ]; then
      echo " :: ERROR: ``apt-get`` upgrade failed"
      exit 255
    fi
  fi
  if [ -f ~/.apt_sources ]; then
    MD5_HASH=$(md5sum ~/.apt_sources | cut -d ' ' -f 1)
    if [[ "$MD5_HASH" != "$MD5_APT_SOURCES" ]]; then
      echo " :: Installing ``apt-get`` sources"
      if [ -z "$MD5_APT_SOURCES" ]; then
        echo "export MD5_APT_SOURCES=$MD5_HASH" >> $ENVIRONMENT
      else
        sed -i "s/$MD5_APT_SOURCES/$MD5_HASH/" "$ENVIRONMENT"
      fi
      while read src; do
        sudo add-apt-repository $src &>/dev/null
      done < ~/.apt_sources
    fi
    unset MD5_HASH
  fi
  if [ -f ~/.apt_apps ]; then
    MD5_HASH=$(md5sum ~/.apt_apps | cut -d ' ' -f 1)
    if [[ "$MD5_HASH" != "$MD5_APT_APPS" ]]; then
      echo " :: Installing ``apt-get`` required apps"
      if [ -z "$MD5_APT_APPS" ]; then
        echo "export MD5_APT_APPS=$MD5_HASH" >> $ENVIRONMENT
      else
        sed -i "s/$MD5_APT_APPS/$MD5_HASH/" "$ENVIRONMENT"
      fi
      while read app; do
        APP_INSTALLED=$(which $app)
        if [ -z "$APP_INSTALLED" ]; then
          sudo apt-get -qq install $app &>/dev/null
        fi
        unset APP_INSTALLED
      done < ~/.apt_apps
    fi
    unset MD5_HASH
  fi
fi

echo ":: Verifying user shell"
USER_SHELL=$(basename $SHELL)
if [ "$USER_SHELL" != "zsh" ]; then
  ZSH=$(which zsh)
  if [ -z $ZSH ]; then
    if [ "$OS_PREFIX" == "osx" ]; then
      eval $BREW install zsh &>/dev/null
      if [ $? != 0 ]; then
        echo ":: ERROR: ``zsh`` install failed"
        exit 255
      fi
    elif [ "$OS_PREFIX" == "ubuntu" ]; then
      echo "Install on ubuntu"
      sudo apt-get -qq install zsh -y
      if [ $? != 0 ]; then
        echo ":: ERROR: ``zsh`` install failed"
        exit 255
      fi
    fi
  fi
  ZSH=$(which zsh)
  if [ ! -z $ZSH ]; then
    sudo chsh -s "$ZSH"  &>/dev/null
    if [ $? != 0 ]; then
      echo ":: ERROR: ``zsh`` cannot be set as shell"
      exit 255
    fi
  fi
fi


echo ":: Verifying ``.dotfiles`` updates"

unset BREW
unset BREW_UPDATES
unset CONFIGURE_DOT_FILES
unset DOT_FILES
unset DOT_FILES_INSTALL
unset DOT_FILES_PUSH
unset ENVIRONMENT
unset GIT
unset GREEN
unset INSTALL_DOT_FILES
unset NC
unset UPDATE_DOT_FILES
unset OS_PREFIX
unset RED
unset REPLACE
unset REPLACE2
unset USER_SHELL
unset ZSH
unset YELLOW

rm ~/.update_in_progress
echo ":: Verified environment"
