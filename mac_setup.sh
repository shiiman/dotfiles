#!/bin/bash

# Homebrewのインストール
if ! type brew >/dev/null 2>&1; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# gitから設定ファイルをclone
if ! type git >/dev/null 2>&1; then
    brew install git
fi
git clone https://github.com/bayguh/dotfiles.git ~/dotfiles

# 設定ファイルフォルダに移動
cd ~/dotfiles
# ローカルリポジトリにユーザのメールアドレス登録
git config user.email hsnonsense5@gmail.com
# bundleインストール
brew tap Homebrew/bundle
# アプリインストール
brew bundle

##################################################################

# dotfileの設定
sh ~/dotfiles/dotfile_setup.sh

# zshをシェルリストに追加
sudo sh -c "echo /usr/local/bin/zsh >> /etc/shells"
# デフォルトシェルをzshに変更
chsh -s /usr/local/bin/zsh

# anyenvの設定
sh ~/dotfiles/anyenv_setup.sh

# fzfをインストール
sh /usr/local/opt/fzf/install

# gcloud補完設定
# python2系が必要(3系では未対応)
if [ ! -e ~/.config/gcloud/gcloud-zsh-completion ]; then
    mkdir -p  ~/.config/gcloud
    git clone https://github.com/littleq0903/gcloud-zsh-completion.git ~/.config/gcloud/gcloud-zsh-completion
fi

# sublime textの設定
sh ~/dotfiles/SublimeText3/sublime_setup.sh

# tarの設定変更
ln -s /usr/local/opt/gnu-tar/bin/gtar /usr/local/bin/tar

# finderで隠しファイルの表示
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

##################################################################

cp -f ~/dotfiles/Fonts/Ricty*.ttf ~/Library/Fonts/
fc-cache -fv

# neovimでpython3を使えるように設定
pip3 install --user --upgrade neovim

# PHP_CodeSnifferインストール
# curl -O http://pear.php.net/go-pear.phar
# php -d detect_unicode=0 go-pear.phar
# ~/pear/bin/pear install PHP_CodeSniffer
# rm -rf go-pear.phar
