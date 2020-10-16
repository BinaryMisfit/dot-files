#!/usr/bin/env bash

set -o pipefail

FAILED_EXIT=0
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
  FAILED_EXIT=$(( $FAILED_EXIT + $? ))
  CONFIGURE_DOT_FILES=true
fi

if [ "$UPDATE_DOT_FILES" == true ]; then
  echo ":: Reconfiguring environment"
  pushd $DOT_FILES &>/dev/null
  git remote update --prune &>/dev/null
  FAILED_EXIT=$(( $FAILED_EXIT + $? ))
  popd &>/dev/null
fi

if [ "$CONFIGURE_DOT_FILES" == true ]; then
  ~/.dotfiles/install
fi

if [ "$OS_PREFIX" == "osx" ]; then
  if [ -z $BREW ]; then
    echo ":: Installing ``brew``"
    CI=1 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &>/dev/null
    FAILED_EXIT=$(( $FAILED_EXIT + $? ))
  else
    brew outdated
    FAILED_EXIT=$(( $FAILED_EXIT + $? ))
  fi
fi

if [ "$OS_PREFIX" == "ubuntu" ]; then
  APT_UPDATE=$(sudo apt-get -qq upgrade --dry-run)
  FAILED_EXIT=$(( $FAILED_EXIT + $? ))
  if [ -z $APT_UPDATE ] && [ $FAILED_EXIT == 0 ]; then
    sudo apt-get -qq upgrade -y --dry-run
  fi
fi

if [ $FAILED_EXIT == 0 ]; then
  echo ":: Environment updated"
fi
