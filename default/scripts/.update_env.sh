#!/usr/bin/env bash

if [ -f ~/.update_in_progress ]; then
  exit 0
fi

touch ~/.update_in_progress

INSTALL_DOT_FILES=false
UPDATE_DOT_FILES=true
CONFIGURE_DOT_FILES=false
DOT_FILES=~/.dotfiles
ENVIRONMENT=~/.environment.zsh
GIT=$(which git)
BREW=$(which brew)
OS_PREFIX=
DOT_FILES_PUSH=
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_PREFIX="osx"
elif [ "$OSTYPE" == "linux-gnu" ]; then
  OS_PREFIX=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print tolower($1)}')
fi

if [ -z $OS_PREFIX ]; then
  echo ":: ERROR: Unknown OS $OSTYPE"
  exit 255
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

if [ ! -f "$ENVIRONMENT" ]; then
    touch "$ENVIRONMENT"
fi

unset COLORTERM
unset DEFAULT_USER
unset ITERM2_SQUELCH_MARK
unset KEYTIMEOUT
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

if [ "$INSTALL_DOT_FILES" == true ]; then
  echo ":: Configuring environment"
  git clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules --quiet &>/dev/null
  if [ $? != 0 ]; then
    echo ":: ERROR: Git clone failed for ``.dotfiles``"
    exit 255
  fi
  CONFIGURE_DOT_FILES=true
fi

if [ "$UPDATE_DOT_FILES" == true ]; then
  echo ":: Reconfiguring environment"
  pushd $DOT_FILES &>/dev/null
  #  git remote update --prune &>/dev/null
  CURRENT_BRANCH=$(git branch --show-current)
  if [ $? != 0 ]; then
    echo ":: ERROR: Git branch failed for ``.dotfiles``"
    exit 255
  fi
  CURRENT_HEAD=$(git log --pretty=%H ...refs/heads/$CURRENT_BRANCH^)
  if [ $? != 0 ]; then
    echo ":: ERROR: Git log failed for ``.dotfiles``"
    exit 255
  fi
  REMOTE_HEAD=$(git ls-remote origin -h refs/heads/$CURRENT_BRANCH | cut -f1)
  if [ $? != 0 ]; then
    echo ":: ERROR: Git remote failed for ``.dotfiles``"
    exit 255
  fi
  if [ "$CURRENT_HEAD" != "$REMOTE_HEAD" ]; then
    CONFIGURE_DOT_FILES=true
    git pull --quiet &>/dev/null
    if [ $? != 0 ]; then
      echo ":: ERROR: Git pull failed for ``.dotfiles``"
      exit 255
    fi
    git submodule --quiet foreach 'git checkout master --quiet && git pull --quiet' &>/dev/null
    if [ $? != 0 ]; then
      echo ":: ERROR: Git submodule failed for ``.dotfiles``"
      exit 255
    fi
  fi
  DOT_FILES_PUSH=$(git status -s)
  if [ $? != 0 ]; then
    echo ":: ERROR: Git status failed for ``.dotfiles``"
    exit 255
  fi
  if [ ! -z "$DOT_FILES_PUSH" ]; then
    CONFIGURE_DOT_FILES=true
  fi
  popd &>/dev/null
fi

if [ "$CONFIGURE_DOT_FILES" == true ]; then
  ~/.dotfiles/install &>/dev/null
  if [ $? != 0 ]; then
    echo ":: ERROR: ``dotfiles/install`` failed"
    exit 255
  fi
  pushd $DOT_FILES &>/dev/null
  DOT_FILES_PUSH=$(git status -s)
  if [ $? != 0 ]; then
    echo ":: ERROR: Git status failed for ``.dotfiles``"
    exit 255
  fi
  popd &>/dev/null
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
    echo ":: ERROR: ``apt-get`` upgrade failed"
    exit 255
  fi
  if [ ! -z "$APT_UPDATE" ]; then
    echo ":: Updating packages"
    APT_UPGRADE=$(sudo apt-get -qq upgrade -y)
    if [ $? != 0 ]; then
      echo ":: ERROR: ``apt-get`` upgrade failed"
      exit 255
    fi
  fi
fi

USER_SHELL=$(basename $SHELL)
if [ "$USER_SHELL" != "zsh" ]; then
  ZSH=$(which zsh)
  echo $ZSH
fi


if [ ! -z "$DOT_FILES_PUSH" ]; then
  echo ":: ``.dotfiles`` needs to be pushed"
fi

unset DOT_FILES_PUSH
unset BREW
unset CONFIGURE_DOT_FILES
unset DOT_FILES
unset ENVIRONMENT
unset GIT
unset INSTALL_DOT_FILES
unset UPDATE_DOT_FILES
unset OS_PREFIX
unset USER_SHELL
unset ZSH

rm ~/.update_in_progress
echo ":: Environment updated"
