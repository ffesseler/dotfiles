#!/bin/sh

# vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir ~/.vim/colors
cp colors/Tomorrow-Night.vim ../.vim/colors/
cp colors/solarized.vim ../.vim/colors/
vim +PlugInstall +qall
ln -s ~/dotfiles/cheat40.txt ~/.vim

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

wget -O - http://git.io/tmux-up > /usr/local/bin/tmux-up
chmod u+x /usr/local/bin/tmux-up

cp dev2.conf ../dev2.conf
mkdir ~/.m2
cp settings.xml ~/.m2/
cp toolchains.xml ~/.m2/

# fish
echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish
rm -rf ~/.config/fish
ln -s ~/dotfiles/.config/fish ~/.config
