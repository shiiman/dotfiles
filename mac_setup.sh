#!/bin/bash

# Homebrewのインストール.
if ! type brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# GitHubから設定ファイルをclone.
if ! type git >/dev/null 2>&1; then
    brew install git
fi
git clone https://github.com/shiiman/dotfiles.git ~/dotfiles

# 設定ファイルフォルダに移動.
cd ~/dotfiles
# ローカルリポジトリにユーザのメールアドレス登録.
git config user.email hsnonsense5@gmail.com

# bundleインストール.
brew tap Homebrew/bundle
# アプリインストール.
brew bundle

##################################################################

# dotfileの設定.
sh ~/dotfiles/dotfile_setup.sh

# zshがデフォルトになったのでコメントアウト.
# # zshをシェルリストに追加.
# sudo sh -c "echo /usr/local/bin/zsh >> /etc/shells"
# #デフォルトシェルをzshに変更.
# chsh -s /usr/local/bin/zsh
# #ディレクトリ権限変更.
# chmod 755 /usr/local/share/zsh
# chmod 755 /usr/local/share/zsh/site-functions


# anyenvの設定.
sh ~/dotfiles/anyenv_setup.sh

# fzfをインストール.
#sh /usr/local/opt/fzf/install
sh /opt/homebrew/opt/fzf/install

# gcloud補完設定.
# python2系が必要(3系では未対応).
if [ ! -e ~/.config/gcloud/gcloud-zsh-completion ]; then
    mkdir -p  ~/.config/gcloud
    git clone https://github.com/littleq0903/gcloud-zsh-completion.git ~/.config/gcloud/gcloud-zsh-completion
fi

# sublime textの設定.(一度sublimeを起動する必要があるかも.)
sh ~/dotfiles/SublimeText/sublime_setup.sh

# finderで隠しファイルの表示.
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

##################################################################

# フォントの設定.
cp -f ~/dotfiles/Fonts/Ricty*.ttf ~/Library/Fonts/
fc-cache -fv
