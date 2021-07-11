# P10K Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load environment
#test -e ${HOME}/.scripts/update_online.sh && /bin/bash ${HOME}/.scripts/update_online.sh
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh
test -e ${HOME}/.antigen/antigen.zsh && source ${HOME}/.antigen/antigen.zsh
test -e ${HOME}/.antigenrc && antigen init ${HOME}/.antigenrc

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
test -e /usr/local/bin/mono && export MONO_GAC_PREFIX="/usr/local"
test -e /usr/local/share/dotnet/dotnet && export MSBuildSDKsPath="/usr/local/share/dotnet/sdk/$(dotnet --version)/Sdks"
test -e /usr/libexec/java_home && export JAVA_HOME="$(/usr/libexec/java_home)"

# Source config files
test -e ${HOME}/.p10k.zsh && source ${HOME}/.p10k.zsh
test -e ${HOME}/.acme.sh/acme.sh.env && source ${HOME}/.acme.sh/acme.sh.env

# Additional setups
autoload -U compinit && compinit
unsetopt BEEP

# Export aliases
test -e /usr/local/bin/nvim && alias sudoedit="sudo /usr/local/bin/nvim "
test -e /usr/local/bin/nvim && alias vi="/usr/local/bin/nvim "
test -e /usr/local/bin/nvim && alias vim="/usr/local/bin/nvim "
test -e /usr/local/bin/tmux && alias tm="/usr/local/bin/tmux attach || /usr/local/bin/tmux new-session"
test -e /usr/local/bin/tmux && alias tl="/usr/local/bin/tmux list-sessions"

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
