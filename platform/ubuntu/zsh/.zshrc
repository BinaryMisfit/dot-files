# Run local config
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh
test -e ${HOME}/.zshrc.local && source ${HOME}/.zshrc.local

# Check for updates
test -e ${HOME}/.dotfiles/deploy/update_online.sh && /bin/bash ${HOME}/.dotfiles/deploy/update_online.sh

# P10K Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load environment
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

# Variables
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export POWERLEVEL9K_MODE=nerdfont-complete

# Load Antigen
test -e /usr/share/zsh-antigen/antigen.zsh && source /usr/share/zsh-antigen/antigen.zsh
test -e ${HOME}/.antigenrc && antigen init ${HOME}/.antigenrc

# Optional Variables
test -e $(which java) && export JAVA_HOME="$($(which java) -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home'  | awk '{ print $3 }')"
test -e /usr/bin/nvim && export EDITOR=$(which nvim)

# Source config files
test -e ${HOME}/.p10k.zsh && source ${HOME}/.p10k.zsh

# Additional setups
autoload -U compinit && compinit
unsetopt BEEP

# Export aliases
test -e /usr/bin/nvim && alias sudoedit="sudo nvim "

# Update PATH
test -e ${HOME}/.npm_global && PATH=${HOME}/.npm_global/bin:$PATH
test -e ${HOME}/.yarn/bin && PATH=${HOME}/.yarn/bin:$PATH
test -e /usr/local/sbin && PATH=/usr/local/sbin:$PATH


# Cleanup
typeset -U PATH
export PATH
