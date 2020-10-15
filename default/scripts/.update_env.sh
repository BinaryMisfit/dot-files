#!/bin/bash
echo "Update environment"
UPDATE_DOT_FILES=true
DOT_FILES=~/.dotfiles
GIT=$(which git)
OS_PREFIX=
if [[ "${OSTYPE}" == "darwin"* ]]; then
  OS_PREFIX="osx"
elif [[ "${OSTYPE}" == "linux-gnu" ]]; then
  OS_PREFIX=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
fi

if [[ -z ${OS_PREFIX} ]]; then
  echo "Unknown OS: ${OSTYPE}"
  exit 1
fi

echo ${OS_PREFIX}
if [ ! -d "$DOT_FILES" ]; then
  UPDATE_DOT_FILES=false
  echo "Shell configuration scripts not installed"
fi

if [ -z "$GIT" ]; then
  UPDATE_DOT_FILES=false
  echo "Skipping dotfiles update (Git not found)"
fi

if [ "$UPDATE_DOT_FILES" == true ]; then
  pushd $DOT_FILES > /dev/null
  git pull --recurse-submodules
  popd > /dev/null
fi

echo "Update completed"
