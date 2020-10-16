#!/usr/bin/env bash

set -o pipefail

INSTALL_DOT_FILES=false
UPDATE_DOT_FILES=true
CONFIGURE_DOT_FILES=false
DOT_FILES=~/.dotfiles
GIT=$(which git)
BREW=$(which brew)
OS_PREFIX=
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_PREFIX="osx"
elif [ "$OSTYPE" == "linux-gnu" ]; then
  OS_PREFIX=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
fi

if [ -z $OS_PREFIX ]; then
  echo "Unknown OS: $OSTYPE"
  exit 1
fi

if [ ! -d "$DOT_FILES" ]; then
  UPDATE_DOT_FILES=false
  INSTALL_DOT_FILES=true
fi

if [ -z "$GIT" ]; then
  UPDATE_DOT_FILES=false
  INSTALL_DOT_FILES=false
  echo ":: ERROR: Skipping dotfiles (\`git\` not found)"
fi

if [ "$INSTALL_DOT_FILES" == true ]; then
  echo ":: Configuring environment"
  git clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules --quiet
  if [ $? != 0 ]; then
    echo ":: ERROR: Git failed for ``.dotfiles``"
    exit 255
  fi
  CONFIGURE_DOT_FILES=true
fi

if [ "$UPDATE_DOT_FILES" == true ]; then
  echo ":: Reconfiguring environment"
  pushd $DOT_FILES &>/dev/null
  git remote update --prune &>/dev/null
  if [ $? != 0 ]; then
    echo ":: ERROR: Git failed for ``.dotfiles``"
    exit 255
  fi
  popd &>/dev/null
fi

if [ "$CONFIGURE_DOT_FILES" == true ]; then
  ~/.dotfiles/install
fi

if [ "$OS_PREFIX" == "osx" ]; then
  if [ -z $BREW ]; then
    CI=1 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &>/dev/null
    if [ $? != 0 ]; then
      echo ":: ERROR: ``brew`` installation failed"
      exit 255
    fi
  else
    brew outdated
    if [ $? != 0 ]; then
      echo ":: ERROR: ``brew`` command failed"
      exit 255
    fi
  fi
fi

if [ "$OS_PREFIX" == "ubuntu" ]; then
  APT_UPDATE=$(sudo apt-get -qq upgrade --dry-run)
  if [ $? != 0 ]; then
    echo ":: ERROR: ``apt-get`` command failed"
    exit 255
  fi
  echo $APT_UPDATE
  if [ -z $APT_UPDATE ]; then
    echo ":: Updating packages"
    APT_UPGRADE=$(sudo apt-get -qq upgrade -y)
    if [ $? != 0 ]; then
      echo ":: ERROR: ``apt-get`` upgrade failed"
      exit 255
    fi
  fi
fi

echo ":: Environment updated"
