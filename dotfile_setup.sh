#!/bin/bash

# 通常のドットファイルを定義.
DOT_FILES=(.bashrc .zshrc .sshrc .gitconfig .gitignore_global .tmux.conf .vimrc)

# ホームディレクトリ配下にシンボリックリンクをはる.
for file in ${DOT_FILES[@]}
do
    ln -sf ~/dotfiles/$file ~/$file
done

#################################################################
# sshrc関連                                                     #
#################################################################
# sshrcの設定ファイル管理用のフォルダ作成
if [ ! -e ~/.sshrc.d ]; then
    mkdir ~/.sshrc.d
fi

# bashの設定ファイルをシンボリックリンク化.
ln -sf ~/dotfiles/.bashrc ~/.sshrc.d/.bashrc
# zshの設定ファイルをシンボリックリンク化.
ln -sf ~/dotfiles/.zshrc ~/.sshrc.d/.zshrc
# vimの設定ファイルをシンボリックリンク化.
ln -sf ~/dotfiles/.vimrc ~/.sshrc.d/.vimrc
