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

echo ":: Verifying environment"
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

echo ":: Verifying ``.dotfiles``"
if [ "$INSTALL_DOT_FILES" == true ]; then
  echo " :: Installing ``.dotfiles``"
  git clone https://github.com/BinaryMisfit/dot-files.git ~/.dotfiles --recurse-submodules --quiet &>/dev/null
  if [ $? != 0 ]; then
    echo " :: ERROR: Git clone failed for ``.dotfiles``"
    exit 255
  fi
  CONFIGURE_DOT_FILES=true
fi

if [ "$UPDATE_DOT_FILES" == true ]; then
  echo " :: Checking for latest ``.dotfiles``"
  pushd $DOT_FILES &>/dev/null
  #  git remote update --prune &>/dev/null
  CURRENT_BRANCH=$(git branch --show-current)
  if [ $? != 0 ]; then
    echo " :: ERROR: Git branch failed for ``.dotfiles``"
    exit 255
  fi
  CURRENT_HEAD=$(git log --pretty=%H ...refs/heads/$CURRENT_BRANCH^)
  if [ $? != 0 ]; then
    echo " :: ERROR: Git log failed for ``.dotfiles``"
    exit 255
  fi
  REMOTE_HEAD=$(git ls-remote origin -h refs/heads/$CURRENT_BRANCH | cut -f1)
  if [ $? != 0 ]; then
    echo " :: ERROR: Git remote failed for ``.dotfiles``"
    exit 255
  fi
  if [ "$CURRENT_HEAD" != "$REMOTE_HEAD" ]; then
    echo " :: Updating ``.dotfiles``"
    CONFIGURE_DOT_FILES=true
    git pull --quiet &>/dev/null
    if [ $? != 0 ]; then
      echo " :: ERROR: Git pull failed for ``.dotfiles``"
      exit 255
    fi
  fi
  DOT_FILES_PUSH=$(git status -s)
  if [ $? != 0 ]; then
    echo " :: ERROR: Git status failed for ``.dotfiles``"
    exit 255
  fi
  if [ ! -z "$DOT_FILES_PUSH" ]; then
    CONFIGURE_DOT_FILES=true
  fi
  popd &>/dev/null
fi

if [ "$CONFIGURE_DOT_FILES" == true ]; then
  echo ":: Running ``.dotfiles`` install"
  ~/.dotfiles/install &>/dev/null
  if [ $? != 0 ]; then
    echo " :: ERROR: ``dotfiles/install`` failed"
    exit 255
  fi
  pushd $DOT_FILES &>/dev/null
  DOT_FILES_PUSH=$(git status -s)
  if [ $? != 0 ]; then
    echo " :: ERROR: Git status failed for ``.dotfiles``"
    exit 255
  fi
  popd &>/dev/null
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
    brew update &>/dev/null
    if [ $? != 0 ]; then
      echo " :: ERROR: ``brew`` update failed"
      exit 255
    fi
    BREW_UPDATES=$(brew outdated)
    echo " :: Verifying ``brew`` packages"
    if [ $? != 0 ]; then
      echo " :: ERROR: ``brew`` outdated failed"
      exit 255
    fi
    if [ ! -z "$BREW_UPDATES" ]; then
      echo " :: Upgrading ``brew`` packages"
      brew upgrade &>/dev/null
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
        BREW_APP=$(brew ls --versions $app)
        if [ -z "$BREW_APP" ]; then
          brew install $app &>/dev/null
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
    echo $MD5_HASH
    if [[ "$MD5_HASH" != "$MD5_APT_SOURCES" ]]; then
      echo " :: Installing ``apt-get`` sources"
      if [ -z "$MD5_APT_SOURCES" ]; then
        echo "export MD5_APT_SOURCES=$MD5_HASH" >> $ENVIRONMENT
      else
        sed -i '' "s/$MD5_APT_SOURCES/$MD5_HASH/" $ENVIRONMENT
      fi
      while read src; do
        sudo add-apt-repository $src -y &>/dev/null
      done < ~/.apt_sources
    fi
    unset MD5_HASH
  fi
  if [ -f ~/.apt_apps ]; then
    MD5_HASH=$(md5sum ~/.apt_sources | cut -d ' ' -f 1)
    if [[ "$MD5_HASH" != "$MD5_APT_APPS" ]]; then
      echo " :: Installing ``apt-get`` sources"
      if [ -z "$MD5_APT_SOURCES" ]; then
        echo "export MD5_APT_APPS=$MD5_HASH" >> $ENVIRONMENT
      else
        sed -i '' "s/$MD5_APT_APPS/$MD5_HASH/" $ENVIRONMENT
      fi
      while read app; do
        sudo apt-get -qq install $app
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
      brew install zsh &>/dev/null
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
if [ ! -z "$DOT_FILES_PUSH" ]; then
  echo " :: ``.dotfiles`` needs to be pushed"
fi

unset BREW
unset BREW_UPDATES
unset CONFIGURE_DOT_FILES
unset DOT_FILES
unset DOT_FILES_PUSH
unset ENVIRONMENT
unset GIT
unset INSTALL_DOT_FILES
unset UPDATE_DOT_FILES
unset OS_PREFIX
unset USER_SHELL
unset ZSH

rm ~/.update_in_progress
echo ":: Verified environment"
