#!/bin/bash

# パスを変数化
packeges_path=~/Library/Application\ Support/Sublime\ Text\ 3/Packages
installed_packeges_path=~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages

# packagesをシンボリックリンク
if [ -d "${packeges_path}" ] && [ -L "${packeges_path}" ]; then
    unlink "${packeges_path}"
elif [ -d "${packeges_path}" ] && [ ! -L "${packeges_path}" ]; then
    rm -rf "${packeges_path}"
fi
ln -sf ~/dotfiles/SublimeText3/Packages "${packeges_path}"

# installed_packagesをシンボリックリンク
if [ -d "${installed_packeges_path}" ] && [ -L "${installed_packeges_path}" ]; then
    unlink "${installed_packeges_path}"
elif [ -d "${installed_packeges_path}" ] && [ ! -L "${installed_packeges_path}" ]; then
    rm -rf "${installed_packeges_path}"
fi
ln -sf ~/dotfiles/SublimeText3/Installed\ Packages "${installed_packeges_path}"
