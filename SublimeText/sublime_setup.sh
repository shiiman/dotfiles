#!/bin/bash
set -e

# パスを変数化
packages_path=~/Library/Application\ Support/Sublime\ Text/Packages
installed_packages_path=~/Library/Application\ Support/Sublime\ Text/Installed\ Packages

# packagesをシンボリックリンク
if [ -d "${packages_path}" ] && [ -L "${packages_path}" ]; then
    unlink "${packages_path}"
elif [ -d "${packages_path}" ] && [ ! -L "${packages_path}" ]; then
    rm -rf "${packages_path}"
fi
ln -sf ~/dotfiles/SublimeText/Packages "${packages_path}"

# installed_packagesをシンボリックリンク
if [ -d "${installed_packages_path}" ] && [ -L "${installed_packages_path}" ]; then
    unlink "${installed_packages_path}"
elif [ -d "${installed_packages_path}" ] && [ ! -L "${installed_packages_path}" ]; then
    rm -rf "${installed_packages_path}"
fi
ln -sf ~/dotfiles/SublimeText/Installed\ Packages "${installed_packages_path}"
