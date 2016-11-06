#!/bin/

# vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp colors/Tomorrow-Night.vim ../.vim/colors
cp colors/solarized.vim ../.vim/colors
vim +PluginInstall +qall

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

wget -O - http://git.io/tmux-up > /usr/local/bin/tmux-up
chmod u+x /usr/local/bin/tmux-up

cp dev2.conf ../dev2.conf

