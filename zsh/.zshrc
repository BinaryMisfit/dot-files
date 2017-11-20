#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
test -e "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" && source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

# Customize to your needs...
# Build PATH
test -e "/usr/local/bin/brew" && export PATH="/usr/local/sbin:$PATH" 
test -e "/usr/local/opt/sqlite/bin" && export PATH="/usr/local/opt/sqlite/bin:$PATH"
test -e "$HOME/Library/Android/sdk/platform-tools/" && export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
test -e "$HOME/.rvm/bin" && export PATH="$PATH:$HOME/.rvm/bin"

# Build LDFLAGS
test -e "/usr/local/opt/gettext/lib" && export LDFLAGS="-L/usr/local/opt/gettext/lib $LDFLAGS"
test -e "/usr/local/opt/icu4c/lib" && export LDFLAGS="-L/usr/local/opt/icu4c/lib $LDFLAGS"
test -e "/usr/local/opt/libffi/lib" && export LDFLAGS="-L/usr/local/opt/libffi/lib $LDFLAGS"
test -e "/usr/local/opt/openssl/lib" && export LDFLAGS="-L/usr/local/opt/openssl/lib $LDFLAGS"

# Build CPPFLAGS
test -e "/usr/local/opt/gettext/include" && export CPPFLAGS="-I/usr/local/opt/gettext/include $CPPFLAGS"
test -e "/usr/local/opt/icu4c/include" && export CPPFLAGS="-I/usr/local/opt/icu4c/include $CPPFLAGS"
test -e "/usr/local/opt/openssl/include" && export CPPFLAGS="-I/usr/local/opt/openssl/include $CPPFLAGS"

# Build PKG_CONFIG
test -e "/usr/local/opt/icu4c/lib/pkgconfig" && export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig:$PKG_CONFIG_PATH"
test -e "/usr/local/opt/libffi/lib/pkgconfig" && export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig:$PKG_CONFIG_PATH"
test -e "/usr/local/opt/openssl/lib/pkgconfig" && export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig:$PKG_CONFIG_PATH"

# Export environment variables 
test -e "/usr/local/bin/brew" && export HOMEBREW_GITHUB_API_TOKEN="4c392dee7b0775db22adcc3dde1ed8cbc7a411ae"
test -e "/usr/local/bin/mvim" && export EDITOR="mvim -v"
test -e "/usr/local/bin/mvim" && export VISUAL="mvim -v"
test -e "${HOME}/.nvm" && export NVM_DIR="${HOME}/.nvm"
test -e "/Library/Java/JavaVirtualMachines/jdk1.8.0_111.jdk/Contents/Home" && export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_111.jdk/Contents/Home"

# Export aliases
test -e "/usr/local/bin/brew" && alias brew-update="brew update; brew upgrade; brew cleanup; brew doctor"
test -e "/usr/local/bin/mvim" && alias vi="mvim -v"

# Source additional scripts
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Additional setups
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
fpath=(/usr/local/share/zsh-completions $fpath)

# Check if running in iTerm
if [ ! -z $TERM_PROGRAM ] && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    alias tmux="tmux -CC attach || tmux -CC new"
else
    alias tmux="tmux attach || tmux new"
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
