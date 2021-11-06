export COLORTERM=truecolor
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Check for updates
test -e ${HOME}/.dotfiles/deploy/update_online.sh && /bin/bash ${HOME}/.dotfiles/deploy/update_online.sh

# Load Antigen
printf "\r\033[0;92m[  ..  ]\033[0m Session startup"
test -e /opt/homebrew/share/antigen/antigen.zsh && source /opt/homebrew/share/antigen/antigen.zsh
test -e /usr/local/share/antigen/antigen.zsh && source /usr/local/share/antigen/antigen.zsh
test -e ${HOME}/.antigenrc && antigen init ${HOME}/.antigenrc
autoload -U compinit && compinit -u
unsetopt BEEP

# iTerm integration
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

# Source p10k files
test -e ${HOME}/.p10k.zsh && source ${HOME}/.p10k.zsh

# Optional Variables
test -e /usr/libexec/java_home && export JAVA_HOME="$(/usr/libexec/java_home)"
test -e /usr/local/bin/nvim && export EDITOR=/usr/local/bin/nvim
test -e /opt/homebrew/bin/nvim && export EDITOR=/opt/homebrew/bin/nvim

# Export aliases
if [[ -f /usr/local/bin/nvim ]]; then
  alias svi="sudo /usr/local/bin/nvim "
  alias vi="/usr/local/bin/nvim "
  alias vim="/usr/local/bin/nvim "
fi

if [[ -f /opt/homebrew/bin/nvim ]]; then
  alias svi="sudo /opt/homebrew/bin/nvim "
  alias vi="/opt/homebrew/bin/nvim "
  alias vim="/opt/homebrew/bin/nvim "
fi

# Update PATH
test -e $HOME/.npm_global && PATH=$HOME/.npm_global/bin:$PATH

# Cleanup
typeset -U PATH
export PATH

# Run local config
test -e ${HOME}/.zshrc.local && source ${HOME}/.zshrc.local
printf "\r\033[0;92m[  OK  ]\033[0m Session startup\n"
