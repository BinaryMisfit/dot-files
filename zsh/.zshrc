# Variables
export DEFAULT_USER=${USER}
export COLORTERM=truecolor
export ITERM2_SQUELCH_MARK=1
export KEYTIMEOUT=1
export LC_CTYPE=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export ZSH=${HOME}/.oh-my-zsh
export ZSH_THEME=frisk
export ZSH_DISABLE_COMPFIX=true
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=250,underline"

# Plugins
plugins=(
    vundle
    history-substring-search
    zsh-completions
    zsh-autosuggestions
    zsh-navigation-tools
    zsh_reload
    zsh-syntax-highlighting
)

# Configure Keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Set PATH
export PATH=$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH

# Source config files
test -e ${ZSH}/oh-my-zsh.sh && source ${ZSH}/oh-my-zsh.sh
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
#test -e ${HOME}/.p10k.zsh && source ~/.p10k.zsh

# Additional setups
autoload -U compinit && compinit

# Export aliases
test -e /usr/bin/vi && alias sudoedit="sudo /usr/bin/vi "
test -e /usr/local/bin/tmux && alias tmux="tmux attach "

# Cleanup
typeset -U PATH
export PATH
