#! /usr/bin/env bash
rm -rf /tmp/stow*
curl -sL https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz -o /tmp/stow-latest.tar.gz
tar xzf /tmp/stow-latest.tar.gz -C /tmp/
rm /tmp/stow-latest.tar.gz
cd $(ls -d /tmp/stow* | head -n 1)
./configure --prefix=/usr/local
sudo make install
cd
rm -rf /tmp/stow*
sudo rm -rf ${HOME}/.bash* ${HOME}/.gitconfig ${HOME}/.iterm* ${HOME}/.oh-my-zsh ${HOME}/.ssh ${HOME}/.tmux* ${HOME}/.paper* ${HOME}/.profile* ${HOME}/.power* ${HOME}/.vim* ${HOME}/.z*
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=${HOME}/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/bhilburn/powerlevel9k.git ${HOME}/.oh-my-zsh/custom/themes/powerlevel9k
git clone https://04e3f744fdc5092319cf0fc84807c305994daa3c@github.com/BinaryMisfit/dot-osx.git ${HOME}/.dotfiles
sudo rm -rf ${HOME}/.bash* ${HOME}/.gitconfig ${HOME}/.iterm* ${HOME}/.ssh ${HOME}/.tmux* ${HOME}/.paper* ${HOME}/.profile* ${HOME}/.power* ${HOME}/.vim* ${HOME}/.z*
stow --dir=${HOME}/.dotfiles/ --target=${HOME}/ git
stow --dir=${HOME}/.dotfiles/ --target=${HOME}/ iterm
stow --dir=${HOME}/.dotfiles/ --target=${HOME}/ ssh
stow --dir=${HOME}/.dotfiles/ --target=${HOME}/ tmux
stow --dir=${HOME}/.dotfiles/ --target=${HOME}/ vim
stow --dir=${HOME}/.dotfiles/ --target=${HOME}/ zsh
git clone https://github.com/VundleVim/Vundle.vim.git ${HOME}/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm
ssh-keygen -t rsa -b 4096 -f ${HOME}/.ssh/id_rsa -C "$(hostname -s)@misfits.best" -q -N ""
sudo chsh -s `which zsh` ${USER}
