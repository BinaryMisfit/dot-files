# Load environment
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
test -e ${HOME}/.scripts/update_online.sh && /bin/bash ${HOME}/.scripts/update_online.sh
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

# Optional Variables
test -e /usr/libexec/java_home && export JAVA_HOME="$(/usr/libexec/java_home)"

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

# Cleanup
typeset -U PATH
export PATH
cd
