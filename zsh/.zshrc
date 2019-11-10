# Load environment
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh

# Variables
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export POWERLEVEL9K_MODE=nerdfont-complete
export ZSH=${HOME}/.oh-my-zsh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=250,underline"
export ZSH_DISABLE_COMPFIX=true
export ZSH_THEME=powerlevel9k/powerlevel9k

# Plugins
plugins=(
  zsh-completions
  zsh-autosuggestions
  zsh-navigation-tools
  zsh_reload
  zsh-syntax-highlighting
)

# Source config files
test -e ${ZSH}/oh-my-zsh.sh && source ${ZSH}/oh-my-zsh.sh
test -e ${HOME}/.p9k.zsh && source ${HOME}/.p9k.zsh

# Additional setups
autoload -U compinit && compinit
unsetopt BEEP

# Export aliases
test -e /usr/local/bin/nvim && alias sudoedit="sudo /usr/local/bin/nvim "
test -e /usr/local/bin/nvim && alias vi="/usr/local/bin/nvim "
test -e /usr/local/bin/nvim && alias vim="/usr/local/bin/nvim "

# Update PATH
PATH=/usr/local/sbin:${PATH}
PATH=$HOME/.yarn/bin:$PATH

# OS Specific
if [[ "${OSTYPE}" == "darwin"* ]]; then
  PATH=/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}
  PATH=/Library/Frameworks/Python.framework/Versions/3.8/bin:${PATH}
fi

# Cleanup
typeset -U PATH
export PATH
