#!/bin/bash

# 通常のドットファイルを定義.
DOT_FILES=(.bashrc .zshrc .gitconfig .gitignore_global .tmux.conf .vimrc)

# ホームディレクトリ配下にシンボリックリンクをはる.
for file in "${DOT_FILES[@]}"; do
    ln -sf ~/dotfiles/"$file" ~/"$file"
done
