# Run local config
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh
test -e ${HOME}/.zshrc.local && source ${HOME}/.zshrc.local

# Check for updates
test -e ${HOME}/.dotfiles/deploy/update_online.sh && /bin/bash ${HOME}/.dotfiles/deploy/update_online.sh

# P10K Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
    printf "\033[0;94m[ INFO ]\033[3;94m Environment loading\033[0m\n"
  else
    printf "\033[0;92m[ INFO ]\033[0m Environment loading\033[0m\n"
  fi

  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# iTerm integration
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\033[0;92m[  ..  ]\033[0m iTerm integration\033[0m"
fi

test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
if [[ "${VERBOSE_LOGIN}" == "1" ]] && [[ "${ITERM_SHELL_INTEGRATION_INSTALLED}" == "Yes" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m iTerm integration\033[0m\n"
elif [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\r\033[0;93m[ SKIP ]\033[0m iTerm integration\033[0m\n"
fi

# Variables
export COLORTERM=truecolor
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\033[0;94m[ INFO ]\033[3;94m COLORTERM\t${COLORTERM}\033[0m"
  printf "\n\033[0;94m[ INFO ]\033[3;94m LANG\t\t${LANG}\033[0m"
  printf "\n\033[0;94m[ INFO ]\033[3;94m LANGUAGE\t${LANGUAGE}\033[0m"
  printf "\n\033[0;94m[ INFO ]\033[3;94m LC_CTYPE\t${LC_CTYPE}\033[0m"
fi

# Load Antigen
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\n\033[0;92m[  ..  ]\033[0m Loading antigen\033[0m"
fi

test -e /opt/homebrew/share/antigen/antigen.zsh && source /opt/homebrew/share/antigen/antigen.zsh
test -e /usr/local/share/antigen/antigen.zsh && source /usr/local/share/antigen/antigen.zsh
test -e ${HOME}/.antigenrc && antigen init ${HOME}/.antigenrc

if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Loading antigen\033[0m"
  printf "\n\033[0;92m[  ..  ]\033[0m Loading p10k\033[0m"
fi

# Source p10k files
test -e ${HOME}/.p10k.zsh && source ${HOME}/.p10k.zsh

if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Loading p10k\033[0m"
  printf "\n\033[0;92m[  ..  ]\033[0m Loading additional variables\033[0m"
fi

# Optional Variables
test -e /usr/libexec/java_home && export JAVA_HOME="$(/usr/libexec/java_home)"
test -e /usr/local/bin/nvim && export EDITOR=/usr/local/bin/nvim
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Loading additional variables\033[0m"
  printf "\n\033[0;94m[ INFO ]\033[3;94m JAVA_HOME\t${JAVA_HOME}\033[0m"
  printf "\n\033[0;94m[ INFO ]\033[3;94m EDITOR\t\t${EDITOR}\033[0m"
  printf "\n\033[0;92m[  ..  ]\033[0m Loading compinit\033[0m"
fi

# Additional setups
autoload -U compinit && compinit -u
unsetopt BEEP

# Export aliases
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Loading compinit\033[0m"
  printf "\n\033[0;92m[  ..  ]\033[0m Loading aliases\033[0m"
fi

test -e /usr/local/bin/nvim && alias sudoedit="sudo nvim "
test -e /usr/local/bin/nvim && alias vi="nvim "
test -e /usr/local/bin/nvim && alias vim="nvim "

if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Loading aliases\033[0m"
  printf "\n\033[0;92m[  ..  ]\033[0m Updating PATH\033[0m"
fi

# Update PATH
test -e $HOME/.npm_global && PATH=$HOME/.npm_global/bin:$PATH
test -e /usr/local/sbin && PATH=/usr/local/sbin:$PATH
test -e /usr/local/opt/curl/bin/curl && PATH=/usr/local/opt/curl/bin:$PATH
test -e /usr/local/opt/openssl@1.1/bin && PATH=/usr/local/opt/openssl@1.1/bin:$PATH

# Cleanup
typeset -U PATH
export PATH
if [[ "${VERBOSE_LOGIN}" == "1" ]]; then
  printf "\r\033[0;92m[  OK  ]\033[0m Updating PATH\033[0m"
  IFS=: read -rA CURRENT_PATH <<< "${PATH}"
  printf "\n\033[0;94m[ PATH ]\033[3;94m %s\033[0m" "${CURRENT_PATH[@]}"
  printf "\n\033[0;94m[ INFO ]\033[3;94m Environment loaded\033[0m\n"
else
  printf "\r\033[0;92m[ INFO ]\033[0m Environment loaded\033[0m\n"
fi

unset CURRENT_PATH
unset VERBOSE_LOGIN
