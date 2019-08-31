export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=agnoster
DEFAULT_USER=$USER
ZSH_DISABLE_COMPFIX=true
plugins=(
  command-not-found
  systemadmin
  thefuck
  vundle
  xcode
  zsh-completions
  zsh-navigation-tools
  zsh_reload
  zsh-syntax-highlighting
)

# Source oh my ZSH
source $ZSH/oh-my-zsh.sh

# Exports
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# Build PATH
test -e "/usr/local/bin/python3" && export PATH="/Users/wirob/Library/Python/3.7/bin:$PATH"
test -e "/usr/local/share/dotnet/dotnet" && export PATH="/usr/local/share/dotnet/sdk:$PATH"
test -e "/usr/local/opt" && export PATH="/usr/local/opt:$PATH"
test -e "/usr/local/bin/brew" && export PATH="/usr/local/sbin:$PATH" 

# Export environment variables 
test -e "/usr/local/bin/brew" && export HOMEBREW_GITHUB_API_TOKEN="37b2481840fba079edeaf5d808fff915ca03bd7e"

# Export aliases
test -e "/usr/local/bin/brew" && alias brew-update="/usr/local/bin/brew update; brew upgrade; brew cleanup; brew doctor"
test -e "/usr/local/bin/brew" && alias brew-bundle="/usr/local/bin/brew bundle --global "
test -e "/usr/bin/vi" && alias sudoedit="sudo /usr/bin/vi "
test -e "/usr/local/bin/tmux" && alias tmux="/usr/local/bin/tmux attach || /usr/local/bin/tmux new "
test -e "/usr/local/bin/ccat" && alias cat="ccat "
test -e "/usr/local/bin/grc" && alias tail="grc tail "
test -e "/usr/local/bin/code-insiders" && alias code="code-insiders "
test -e "/usr/local/bin/pip" && alias pip-update="pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo pip install -U"
test -e "$HOME/.tmux/plugins/tpm/bin/install_plugins" && alias tpm-install="$HOME/.tmux/plugins/tpm/bin/install_plugins"
test -e "$HOME/.tmux/plugins/tpm/bin/clean_plugins" && alias tpm-clean="$HOME/.tmux/plugins/tpm/bin/clean_plugins"

# Additional setups
autoload -U compinit && compinit

# Cleanup
typeset -U PATH
export PATH

# Print system info
if [ -z "$TMUX" ] 
then
    test -e "/usr/local/bin/screenfetch" && /usr/local/bin/screenfetch -E
fi
