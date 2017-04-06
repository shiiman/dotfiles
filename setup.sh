#!/bin/bash

# 通常のドットファイルを定義
DOT_FILES=(.zshrc)

# ホームディレクトリ配下にシンボリックリンクをはる
for file in ${DOT_FILES[@]}
do
    ln -sf ~/dotfiles/$file ~/$file
done

# vimのプラグインパッケージ管理用のフォルダ作成
if [ ! -d ~/.dein ]; then
    mkdir ~/.dein
fi

# deinの設定ファイルをシンボリックリンク化
ln -sf ~/dotfiles/.dein/dein.toml ~/.dein/dein.toml
ln -sf ~/dotfiles/.dein/dein_lazy.toml ~/.dein/dein_lazy.toml
