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
  CONFIGURE_DOT_FILES=true
fi

if [ "$UPDATE_DOT_FILES" == true ]; then
  echo ":: Reconfiguring environment"
  pushd $DOT_FILES &>/dev/null
  git remote update --prune &>/dev/null
  popd &>/dev/null
fi

if [ "$CONFIGURE_DOT_FILES" == true ]; then
  ~/.dotfiles/install
fi

if [ "$OS_PREFIX" == "osx" ]; then
  if [ -z $BREW ]; then
    echo ":: Installing ``brew``"
    sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    brew outdated
  fi
fi

if [ "$OS_PREFIX" == "ubuntu" ]; then
  sudo apt update -y
fi

echo ":: Environment updated"
