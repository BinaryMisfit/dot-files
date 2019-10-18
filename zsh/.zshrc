# Variables
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh
export LC_CTYPE=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export POWERLEVEL9K_MODE=nerdfont-complete
export ZSH=${HOME}/.oh-my-zsh
export ZSH_THEME=powerlevel9k/powerlevel9k
export ZSH_DISABLE_COMPFIX=true
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=250,underline"

# Plugins
plugins=(
    vi-mode
    vundle
    zsh-completions
    zsh-autosuggestions
    zsh-navigation-tools
    zsh_reload
    zsh-syntax-highlighting
)

# Source config files
test -e ${ZSH}/oh-my-zsh.sh && source ${ZSH}/oh-my-zsh.sh
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
test -e ${HOME}/.powerlevel9k.conf && source ${HOME}/.powerlevel9k.conf

# Additional setups
autoload -U compinit && compinit
unsetopt BEEP

# Export aliases
test -e /usr/bin/vi && alias sudoedit="sudo /usr/bin/vi "
test -e /usr/local/bin/tmux && alias tmux="tmux attach "

# iTerm2
[[ ${LC_TERMINAL} == "iTerm2" ]] && test -e /usr/local/bin/tmux && alias tmux="tmux -CC attach "

# Cleanup
typeset -U PATH
export PATH
