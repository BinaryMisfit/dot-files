#!/bin/bash
if [ -d "/Applications/iTerm2.app" ]; then
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/.iterm2"
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
fi
