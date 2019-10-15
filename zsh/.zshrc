# Variables
export ZSH="${HOME}/.oh-my-zsh"
export LC_CTYPE=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export COLORTERM=truecolor
export SOLARIZED_THEME=light
export ZSH_THEME=agnoster
export DEFAULT_USER=${USER}
export ZSH_DISABLE_COMPFIX=true
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#c0c0c0"

# Plugins
plugins=(
  command-not-found
  vundle
  xcode
  zsh-autosuggestions
  zsh-completions
  zsh-navigation-tools
  zsh_reload
  zsh-syntax-highlighting
)

# Set PATH
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Source oh my ZSH
test -e "${ZSH}/oh-my-zsh.sh" && source ${ZSH}/oh-my-zsh.sh
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Additional setups
autoload -U compinit && compinit

# Export aliases
test -e "/usr/bin/vi" && alias sudoedit="sudo /usr/bin/vi "
test -e "/usr/local/bin/tmux" && alias tmux="tmux attach "

# Cleanup
typeset -U PATH
export PATH

