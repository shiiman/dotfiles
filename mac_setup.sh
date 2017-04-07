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
# bundleインストール
brew tap Homebrew/bundle
# アプリインストール
brew bundle

# dotfileの設定
sh ~/dotfiles/dotfile_setup.sh

# zshをシェルリストに追加
sudo sh -c "echo /usr/local/bin/zsh >> /etc/shells"
# デフォルトシェルをzshに変更
chsh -s /usr/local/bin/zsh

# fzfをインストール
sh /usr/local/opt/fzf/install

# finderで隠しファイルの表示
defaults write com.apple.finder AppleShowAllFiles TRUE
