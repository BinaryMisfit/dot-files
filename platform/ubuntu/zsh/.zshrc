export COLORTERM=truecolor
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LIBGL_ALWAYS_INDIRECT=1
export ITERM2_SQUELCH_MARK=1

# Check for updates
test -e ${HOME}/.dotfiles/deploy/update_online.sh && /bin/bash ${HOME}/.dotfiles/deploy/update_online.sh

# Load Antigen
printf "\r\033[0;92m[  ..  ]\033[0m Session startup"
test -e /usr/share/zsh-antigen/antigen.zsh && source /usr/share/zsh-antigen/antigen.zsh
test -e ${HOME}/.antigenrc && antigen init ${HOME}/.antigenrc
autoload -U compinit && compinit
unsetopt BEEP

# Source p10k files
test -e ${HOME}/.p10k.zsh && source ${HOME}/.p10k.zsh

# iTerm integration
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

# Additional variables
test -e /usr/bin/nvim && export EDITOR=$(which nvim)

# Export aliases
test -e /usr/bin/nvim && alias svi="sudoedit "

# Update PATH
test -e ${HOME}/.npm_global && PATH=${HOME}/.npm_global/bin:$PATH
test -e ${HOME}/.yarn/bin && PATH=${HOME}/.yarn/bin:$PATH
test -e /usr/local/sbin && PATH=/usr/local/sbin:$PATH

# Cleanup
typeset -U PATH
export PATH

# Run local config
test -e ${HOME}/.zshrc.local && source ${HOME}/.zshrc.local
printf "\r\033[0;92m[  OK  ]\033[0m Session startup\n"
