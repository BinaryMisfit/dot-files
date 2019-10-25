# Load environment
test -e ${HOME}/.environment.zsh && source ${HOME}/.environment.zsh

# P9K
export POWERLEVEL9K_DIR_SHOW_WRITABLE=true
export POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon user vcs dir status)
export POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(history command_execution_time load ram disk_usage ssh)
export POWERLEVEL9K_SHORTEN_DELIMITER=""
export POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
export POWERLEVEL9K_SHORTEN_STRATEGY="truncate_last"
export POWERLEVEL9K_STATUS_HIDE_SIGNAME=true
export POWERLEVEL9K_VCS_SHORTEN_LENGTH=3
export POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=6
export POWERLEVEL9K_VCS_SHORTEN_STRATEGY="truncate_middle"

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
    docker
    vundle
    zsh-completions
    zsh-autosuggestions
    zsh-navigation-tools
    zsh_reload
    zsh-syntax-highlighting
)

# Source config files
test -e ${ZSH}/oh-my-zsh.sh && source ${ZSH}/oh-my-zsh.sh
#test -e ${HOME}/.powerlevel9k.conf && source ${HOME}/.powerlevel9k.conf

# Additional setups
autoload -U compinit && compinit
unsetopt BEEP

# Export aliases
test -e /usr/bin/vi && alias sudoedit="sudo /usr/bin/vi "
test -e /usr/local/bin/tmux && alias tmux="/usr/local/bin/tmux attach "
test -e /usr/local/bin/tmux && alias tmux-kill="/usr/local/bin/tmux kill-server"
test -e /usr/local/bin/mvim && alias mvim="/usr/local/bin/mvim -v "
test -e /usr/local/bin/mvim && alias vi="/usr/local/bin/mvim -v "
test -e /usr/local/bin/mvim && alias vim="/usr/local/bin/mvim -v "
test -e /usr/local/bin/mvim && alias sudoedit="sudo /usr/local/bin/mvim -v "

# Update PATH
PATH=${HOME}/.bin:${PATH}

# Cleanup
typeset -U PATH
export PATH
