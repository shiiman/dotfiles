#!/bin/bash

# パスを変数化
packeges_path="~/Library/Application\ Support/Sublime\ Text\ 3/Packages"
installedpackeges_path="~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages"

echo $packeges_path

# packagesをシンボリックリンク
if [ -d ${packeges_path} ] && [ -L ${packeges_path} ]; then
    unlink ${packeges_path}
elif [ -d ${packeges_path} ] && [ ! -L ${packeges_path} ]; then
    rm -rf ${packeges_path}
fi
ln -sf ~/dotfiles/SublimeText3/Packages ${packeges_path}

# installed_packagesをシンボリックリンク
if [ -d ${installedpackeges_path} ] && [ -L ${installedpackeges_path} ]; then
    unlink -rf ${installedpackeges_path}
elif [ -d ${installedpackeges_path} ] && [ ! -L ${installedpackeges_path} ]; then
    rm -rf ${installedpackeges_path}
fi
ln -sf ~/dotfiles/SublimeText3/Installed\ Packages ${installedpackeges_path}

