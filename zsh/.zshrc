export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=agnoster
DEFAULT_USER=$USER
ZSH_DISABLE_COMPFIX=true
plugins=(
  command-not-found
  systemadmin
  vundle
  xcode
  zsh-completions
  zsh-navigation-tools
  zsh_reload
  zsh-syntax-highlighting
)

# Source oh my ZSH
source $ZSH/oh-my-zsh.sh

# Exports
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# Export aliases
test -e "/usr/bin/vi" && alias sudoedit="sudo /usr/bin/vi "

# Additional setups
autoload -U compinit && compinit

# Cleanup
typeset -U PATH
export PATH
