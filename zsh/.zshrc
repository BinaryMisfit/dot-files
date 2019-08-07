export ZSH="$HOME/.oh-my-zsh"
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
ZSH_THEME=agnoster-light
DEFAULT_USER=$USER
ZSH_DISABLE_COMPFIX=true
plugins=(
  brew
  command-not-found
  git
  history-substring-search
  iterm2
  osx
  tmux
  xcode
  zsh_reload
  zsh-syntax-highlighting
  zsh-completions
)

# Source oh my ZSH
source $ZSH/oh-my-zsh.sh

# Build PATH
test -e "/usr/local/bin/brew" && export PATH="/usr/local/sbin:$PATH" 
test -e "/usr/local/opt" && export PATH="/usr/local/opt:$PATH"

# Export environment variables 
test -e "/usr/local/bin/brew" && export HOMEBREW_GITHUB_API_TOKEN="37b2481840fba079edeaf5d808fff915ca03bd7e"

# Export aliases
test -e "/usr/local/bin/brew" && alias brew-update="brew update; brew upgrade; brew cleanup; brew doctor"

# Additional setups
autoload -U compinit && compinit

# Bind ZSH Keys
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Cleanup
typeset -U PATH
export PATH

# Print system info
test -e "/usr/local/bin/screenfetch" && /usr/local/bin/screenfetch -E
