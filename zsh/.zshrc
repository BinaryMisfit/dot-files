# Load environment
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

# P9K
export POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=238
export POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=145
export POWERLEVEL9K_DIR_DEFAULT_BACKGROUND=238
export POWERLEVEL9K_DIR_DEFAULT_FOREGROUND=255
export POWERLEVEL9K_DIR_ETC_BACKGROUND=238
export POWERLEVEL9K_DIR_ETC_FOREGROUND=227
export POWERLEVEL9K_DIR_HOME_BACKGROUND=238
export POWERLEVEL9K_DIR_HOME_FOREGROUND=255
export POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND=238
export POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND=255
export POWERLEVEL9K_DIR_NOT_WRITABLE_BACKGROUND=238
export POWERLEVEL9K_DIR_NOT_WRITABLE_FOREGROUND=160
export POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
export POWERLEVEL9K_DIR_PATH_ABSOLUTE=true
export POWERLEVEL9K_DIR_SHOW_WRITABLE=true
export POWERLEVEL9K_DISK_USAGE_CRITICAL_BACKGROUND=088
export POWERLEVEL9K_DISK_USAGE_CRITICAL_FOREGROUND=255
export POWERLEVEL9K_DISK_USAGE_NORMAL_BACKGROUND=114
export POWERLEVEL9K_DISK_USAGE_NORMAL_FOREGROUND=000
export POWERLEVEL9K_DISK_USAGE_WARNING_BACKGROUND=114
export POWERLEVEL9K_DISK_USAGE_WARNING_FOREGROUND=088
export POWERLEVEL9K_HISTORY_BACKGROUND=248
export POWERLEVEL9K_HISTORY_FOREGROUND=000
export POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon ssh user vcs dir status)
export POWERLEVEL9K_LOAD_CRITICAL_BACKGROUND=088
export POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND=255
export POWERLEVEL9K_LOAD_NORMAL_BACKGROUND=238
export POWERLEVEL9K_LOAD_NORMAL_FOREGROUND=255
export POWERLEVEL9K_LOAD_WARNING_BACKGROUND=238
export POWERLEVEL9K_LOAD_WARNING_FOREGROUND=227
export POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
export POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%{%F{145}%} '
export POWERLEVEL9K_PROMPT_ON_NEWLINE=true
export POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(history command_execution_time load ram disk_usage)
export POWERLEVEL9K_SHORTEN_DELIMITER=""
export POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
export POWERLEVEL9K_SHORTEN_STRATEGY="truncate_last"
export POWERLEVEL9K_STATUS_HIDE_SIGNAME=true
export POWERLEVEL9K_VCS_SHORTEN_LENGTH=3
export POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=6
export POWERLEVEL9K_VCS_SHORTEN_STRATEGY="truncate_middle"
export POWERLEVEL9K_OS_ICON_BACKGROUND=114
export POWERLEVEL9K_OS_ICON_FOREGROUND=000
export POWERLEVEL9K_RAM_BACKGROUND=238
export POWERLEVEL9K_RAM_FOREGROUND=255
export POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND=238
export POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND=227
export POWERLEVEL9K_SSH_BACKGROUND=238
export POWERLEVEL9K_SSH_FOREGROUND=255

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
