# P10K Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load environment
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
#test -e ${HOME}/.scripts/update_online.sh && /bin/bash ${HOME}/.scripts/update_online.sh
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh

# Variables
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export POWERLEVEL9K_MODE=nerdfont-complete
export ZSH=${HOME}/.oh-my-zsh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=250,underline"
export ZSH_DISABLE_COMPFIX=true
export ZSH_THEME=powerlevel10k/powerlevel10k

# Optional Variables
test -e /usr/libexec/java_home && export JAVA_HOME="$(/usr/libexec/java_home)"
test -e /usr/lib/android-sdk && export ANDROID_HOME=/usr/lib/android-sdk
test -e /opt/maven && export M2_HOME=/opt/maven
test -e /opt/maven && export MAVEN_HOME=/opt/maven

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
test -e ${HOME}/.p10k.zsh && source ${HOME}/.p10k.zsh
test -e ${HOME}/.acme.sh/acme.sh.env && source ${HOME}/.acme.sh/acme.sh.env
test -e ${HOME}/.scripts/antigen.zsh && source ${HOME}/.scripts/antigen.zsh

# Additional setups
autoload -U compinit && compinit
unsetopt BEEP

# Export tool variables
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Export aliases
test -e /usr/bin/nvim && alias sudoedit="sudo /usr/bin/nvim "
test -e /usr/bin/nvim && alias vi="/usr/bin/nvim "
test -e /usr/bin/nvim && alias vim="/usr/bin/nvim "
test -e /usr/bin/tmux && alias tm="/usr/bin/tmux attach || /usr/bin/tmux new-session"
test -e /usr/bin/tmux && alias tl="/usr/bin/tmux list-sessions"

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
