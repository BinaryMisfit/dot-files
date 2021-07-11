# P10K Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load environment
#test -e ${HOME}/.scripts/update_online.sh && /bin/bash ${HOME}/.scripts/update_online.sh
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh

# Variables
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export POWERLEVEL9K_MODE=nerdfont-complete
export EDITOR=nvim
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOSTART_ONCE=true
export ZSH_TMUX_AUTOCONNECT=true

# Load Antigen
test -e ${HOME}/.antigen/antigen.zsh && source ${HOME}/.antigen/antigen.zsh
test -e ${HOME}/.antigenrc && antigen init ${HOME}/.antigenrc

# Optional Variables
test -e /usr/libexec/java_home && export JAVA_HOME="$(/usr/libexec/java_home)"
test -e /usr/lib/android-sdk && export ANDROID_HOME=/usr/lib/android-sdk
test -e /opt/maven && export M2_HOME=/opt/maven
test -e /opt/maven && export MAVEN_HOME=/opt/maven

# Source config files
test -e ${HOME}/.p10k.zsh && source ${HOME}/.p10k.zsh
test -e ${HOME}/.acme.sh/acme.sh.env && source ${HOME}/.acme.sh/acme.sh.env

# Additional setups
autoload -U compinit && compinit
unsetopt BEEP

# Export aliases
test -e /usr/bin/nvim && alias sudoedit="sudo nvim "
test -e /usr/bin/tmux && alias tm="tmux attach || tmux new-session"
test -e /usr/bin/tmux && alias tl="tmux list-sessions"

# Update PATH
test -e $HOME/.npm_global && PATH=$HOME/.npm_global/bin:$PATH
test -e $HOME/.yarn/bin && PATH=$HOME/.yarn/bin:$PATH
test -e /usr/local/sbin && PATH=/usr/local/sbin:$PATH
test -e /usr/lib/android-sdk/platform-tools && PATH=/usr/lib/android-sdk/platform-tools:$PATH
test -e /usr/lib/android-sdk/cmdline-tools/tools && PATH=/usr/lib/android-sdk/cmdline-tools/tools:$PATH
test -e /usr/lib/android-sdk/cmdline-tools/tools/bin && PATH=/usr/lib/android-sdk/cmdline-tools/tools/bin:$PATH
test -e /opt/maven && export PATH=$M2_HOME/bin:$PATH}

# Cleanup
typeset -U PATH
export PATH
