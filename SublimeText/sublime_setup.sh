#!/bin/bash

# パスを変数化
packeges_path=~/Library/Application\ Support/Sublime\ Text/Packages
installed_packeges_path=~/Library/Application\ Support/Sublime\ Text/Installed\ Packages

# packagesをシンボリックリンク
if [ -d "${packeges_path}" ] && [ -L "${packeges_path}" ]; then
    unlink "${packeges_path}"
elif [ -d "${packeges_path}" ] && [ ! -L "${packeges_path}" ]; then
    rm -rf "${packeges_path}"
fi
ln -sf ~/dotfiles/SublimeText/Packages "${packeges_path}"

# installed_packagesをシンボリックリンク
if [ -d "${installed_packeges_path}" ] && [ -L "${installed_packeges_path}" ]; then
    unlink "${installed_packeges_path}"
elif [ -d "${installed_packeges_path}" ] && [ ! -L "${installed_packeges_path}" ]; then
    rm -rf "${installed_packeges_path}"
fi
ln -sf ~/dotfiles/SublimeText/Installed\ Packages "${installed_packeges_path}"
