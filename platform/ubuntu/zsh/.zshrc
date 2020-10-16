# Load environment
if [ -z $TMUX ]; then
  test -e ${HOME}/.scripts/.update_env.sh && /bin/bash ${HOME}/.scripts/.update_env.sh
fi
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

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
test -e ${HOME}/.acme.sh/acme.sh.env && source ${HOME}/.acme.sh/acme.sh.env

# Additional setups
autoload -U compinit && compinit
unsetopt BEEP

# Export aliases
test -e /usr/bin/nvim && alias sudoedit="sudo /usr/bin/nvim "
test -e /usr/bin/nvim && alias vi="/usr/bin/nvim "
test -e /usr/bin/nvim && alias vim="/usr/bin/nvim "

# Update PATH
PATH=/usr/local/sbin:${PATH}
PATH=$HOME/.yarn/bin:$PATH

# Cleanup
typeset -U PATH
export PATH
