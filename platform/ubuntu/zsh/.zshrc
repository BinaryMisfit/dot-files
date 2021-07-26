# Run local config
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh
test -e ${HOME}/.zshrc.local && source ${HOME}/.zshrc.local

# Check for updates
test -e ${HOME}/.dotfiles/deploy/update_online.sh && /bin/bash ${HOME}/.dotfiles/deploy/update_online.sh

# Load environment
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
if [[ "${VERBOSE_LOGIN}" == "1" ]] && [[ "${ITERM_SHELL_INTEGRATION_INSTALLED}" == "Yes" ]]; then
  printf "\033[3;93m\n==> iTerm Integrated\t\033[3;97m\033[0m\n"
fi

# Variables
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\033[3;93m\n==> Exported Variables\033[0m\n"
  printf "\033[3;93m    LANG\t\t\033[3;97m${LANG}\033[0m\n"
  printf "\033[3;93m    LANGUAGE\t\t\033[3;97m${LANGUAGE}\033[0m\n"
  printf "\033[3;93m    LC_CTYPE\t\t\033[3;97m${LC_CTYPE}\033[0m\n"
fi

# Load Antigen
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\033[3;93m\n==> Loading antigen\033[0m\n"
fi
test -e /usr/share/zsh-antigen/antigen.zsh && source /usr/share/zsh-antigen/antigen.zsh
test -e ${HOME}/.antigenrc && antigen init ${HOME}/.antigenrc

# Source p10k files
test -e ${HOME}/.p10k.zsh && source ${HOME}/.p10k.zsh

# P10K Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
    printf "\033[3;93m\n==> Instant prompt enabled\033[0m\n"
  fi

  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Additional variables
test -e $(which java) && export JAVA_HOME="$($(which java) -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home'  | awk '{ print $3 }')"
test -e /usr/bin/nvim && export EDITOR=$(which nvim)
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
    printf "\033[3;93m\n==> Additional variables\033[0m\n"
    printf "\033[3;93m    JAVA_HOME:\t\033[3,97m${JAVA_HOME}\033[0m\n"
fi

# ZSH config
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\033[3;93m\n==> Loading compinit\033[0m\n"
fi

autoload -U compinit && compinit
unsetopt BEEP

# Export aliases
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
    printf "\033[3;93m\n==> Loading aliases\033[0m\n"
fi

test -e /usr/bin/nvim && alias sudoedit="sudo nvim "

# Update PATH
test -e ${HOME}/.npm_global && PATH=${HOME}/.npm_global/bin:$PATH
test -e ${HOME}/.yarn/bin && PATH=${HOME}/.yarn/bin:$PATH
test -e /usr/local/sbin && PATH=/usr/local/sbin:$PATH

# Cleanup
typeset -U PATH
export PATH
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\033[3;93m\n==> Final path\033[0m\n"
  printf "\033[3;93m${PATH}\033[0m\n"
fi

unset VERBOSE_LOGIN
