ZSH_DISABLE_COMPFIX=true
# P10K Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load environment
START_TMUX=false
#test -e ${HOME}/.scripts/update_online.sh && /bin/bash ${HOME}/.scripts/update_online.sh
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh
test -e /usr/local/bin/tmux && START_TMUX=true
[ ! -z ${TMUX} ] && START_TMUX=false

# Variables
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export POWERLEVEL9K_MODE=nerdfont-complete
export EDITOR=nvim
export ZSH_TMUX_AUTOSTART=${START_TMUX}
export ZSH_TMUX_AUTOSTART_ONCE=true
export ZSH_TMUX_AUTOCONNECT=true
export ZSH_TMUX_AUTOQUIT=${START_TMUX}

# Load Antigen
test -e /usr/local/share/antigen/antigen.zsh && source /usr/local/share/antigen/antigen.zsh
test -e ${HOME}/.antigenrc && antigen init ${HOME}/.antigenrc

# Optional Variables
test -e /usr/local/bin/mono && export MONO_GAC_PREFIX="/usr/local"
test -e /usr/local/share/dotnet/dotnet && export MSBuildSDKsPath="/usr/local/share/dotnet/sdk/$(dotnet --version)/Sdks"
test -e /usr/libexec/java_home && export JAVA_HOME="$(/usr/libexec/java_home)"

# Source config files
test -e ${HOME}/.p10k.zsh && source ${HOME}/.p10k.zsh
test -e ${HOME}/.acme.sh/acme.sh.env && source ${HOME}/.acme.sh/acme.sh.env

# Additional setups
autoload -U compinit && compinit
unsetopt BEEP
unset START_TMUX

# Export aliases
test -e /usr/local/bin/nvim && alias sudoedit="sudo nvim "
test -e /usr/local/bin/nvim && alias vi="nvim "
test -e /usr/local/bin/nvim && alias vim="nvim "
test -e /usr/local/bin/tmux && alias tm="tmux attach || tmux new-session"
test -e /usr/local/bin/tmux && alias tl="tmux list-sessions"

# Update PATH
test -e $HOME/Library/Android/sdk/platform-tools && PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
test -e $HOME/Library/Android/sdk/tools/bin && PATH=$PATH:$HOME/Library/Android/sdk/tools/bin
test -e $HOME/.npm_global && PATH=$HOME/.npm_global/bin:$PATH
test -e $HOME/.yarn/bin && PATH=$HOME/.yarn/bin:$PATH
test -e /usr/local/sbin && PATH=/usr/local/sbin:$PATH
test -e /usr/local/opt/curl/bin/curl && PATH=/usr/local/opt/curl/bin:$PATH
test -e /usr/local/opt/openssl@1.1/bin && PATH=/usr/local/opt/openssl@1.1/bin:$PATH

# Cleanup
typeset -U PATH
export PATH
