#!/bin/bash

# パスを変数化
packeges_path=~/Library/Application\ Support/Code/User

# 設定ファイルをシンボリックリンク ===================================
if [ -d "${packeges_path}/keybindings.json" ] && [ -L "${packeges_path}/keybindings.json" ]; then
    unlink "${packeges_path}/keybindings.json"
elif [ -d "${packeges_path}/keybindings.json" ] && [ ! -L "${packeges_path}/keybindings.json" ]; then
    rm -rf "${packeges_path}/keybindings.json"
fi
ln -sf ~/dotfiles/VSCode/keybindings.json "${packeges_path}/keybindings.json"

if [ -d "${packeges_path}/locale.json" ] && [ -L "${packeges_path}/locale.json" ]; then
    unlink "${packeges_path}/locale.json"
elif [ -d "${packeges_path}/locale.json" ] && [ ! -L "${packeges_path}/locale.json" ]; then
    rm -rf "${packeges_path}/locale.json"
fi
ln -sf ~/dotfiles/VSCode/locale.json "${packeges_path}/locale.json"

if [ -d "${packeges_path}/settings.json" ] && [ -L "${packeges_path}/settings.json" ]; then
    unlink "${packeges_path}/settings.json"
elif [ -d "${packeges_path}/settings.json" ] && [ ! -L "${packeges_path}/settings.json" ]; then
    rm -rf "${packeges_path}/settings.json"
fi
ln -sf ~/dotfiles/VSCode/settings.json "${packeges_path}/settings.json"

# ==============================================================

# snippetsをシンボリックリンク =====================================
if [ -d "${packeges_path}/snippets" ] && [ -L "${packeges_path}/snippets" ]; then
    unlink "${packeges_path}/snippets"
elif [ -d "${packeges_path}/snippets" ] && [ ! -L "${packeges_path}/snippets" ]; then
    rm -rf "${packeges_path}/snippets"
fi
ln -sf ~/dotfiles/VSCode/snippets "${packeges_path}/snippets"

# ==============================================================

# extensionのインストール =========================================
cat ./extensions | while read line
do
    code --install-extension $line
done
# ==============================================================
