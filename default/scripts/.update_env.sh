#!/bin/bash
echo "Update environment"
UPDATE_DOT_FILES=true
DOT_FILES=~/.dotfiles
GIT=$(which git)
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
