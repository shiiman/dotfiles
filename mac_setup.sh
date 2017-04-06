#!/bin/bash

# Homebrewのインストール
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# gitから設定ファイルをclone
git clone https://github.com/bayguh/dotfiles.git ~/dotfiles
# 設定ファイルフォルダに移動
cd ~/dotfiles
# bundleインストール
brew tap Homebrew/bundle
# アプリインストール
brew bundle
# dotfileの設定
sh ~/dotfiles/dotfile_setup.sh

