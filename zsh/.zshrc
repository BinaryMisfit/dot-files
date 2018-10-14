export ZSH="/Users/wirob/.oh-my-zsh"
ZSH_THEME="powerlevel9k/powerlevel9k"
DEFAULT_USER=$USER
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
)

# Source oh my ZSH
source $ZSH/oh-my-zsh.sh

# Build PATH
test -e "/usr/local/bin/brew" && export PATH="/usr/local/sbin:$PATH" 
test -e "/usr/local/opt" && export PATH="/usr/local/opt:$PATH"
test -e "$HOME/.rvm/bin" && export PATH="$HOME/.rvm/bin:$PATH"
test -e "$HOME/Library/Android/sdk/platform-tools/" && export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

# Export environment variables 
test -e "/usr/local/bin/brew" && export HOMEBREW_GITHUB_API_TOKEN="4c392dee7b0775db22adcc3dde1ed8cbc7a411ae"

# Export aliases
test -e "/usr/local/bin/brew" && alias brew-update="brew update; brew upgrade; brew cleanup; brew doctor"

# Source additional scripts
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Additional setups
fpath=(/usr/local/share/zsh-completions $fpath)
export JAVA_HOME=`/usr/libexec/java_home -v 11`

# Bind ZSH Keys
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Check if running in iTerm
if [ ! -z $TERM_PROGRAM ] && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    alias tmux="tmux -u -CC attach || tmux -u -CC new"
else
    alias tmux="tmux -u attach || tmux -u new"
fi

# Cleanup
typeset -U PATH
export PATH
typeset -U LDFLAGS
export LDFLAGS
typeset -U CPPFLAGS
export CPPFLAGS
typeset -U PKG_CONFIG_PATH
export PKG_CONFIG_PATH
