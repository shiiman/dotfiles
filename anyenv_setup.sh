#!/bin/bash

# anyenvのインストール
if [ ! -e ~/.anyenv ]; then
    git clone https://github.com/riywo/anyenv ~/.anyenv
    mkdir -p ~/.anyenv/plugins
    git clone https://github.com/znz/anyenv-update.git ~/.anyenv/plugins/anyenv-update
    git clone git://github.com/aereal/anyenv-exec.git ~/.anyenv/plugins/anyenv-exe
    git clone https://github.com/znz/anyenv-git.git ~/.anyenv/plugins/anyenv-git
fi

echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> /tmp/anyenv.setting
echo 'eval "$(anyenv init -)"' >> /tmp/anyenv.setting

# シェルの再読込
source /tmp/anyenv.setting

# 各envのインストール
anyenv install --init

anyenv install pyenv
anyenv install rbenv
anyenv install phpenv
anyenv install nodenv
anyenv install goenv
anyenv install jenv

# シェルの再読込
source /tmp/anyenv.setting

# macOS SDK header install
if [[ `sw_vers` == *"10.14."* ]] ; then
  sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
fi

# 各言語をインストール
pyenv install 2.7.16
rbenv install 2.6.3
phpenv install 7.2.18
nodenv install 12.3.1
goenv install 1.8.1

jenv add $(/usr/libexec/java_home -v 1.6)
jenv add $(/usr/libexec/java_home -v 1.7)
jenv add $(/usr/libexec/java_home -v 1.8)


# 各言語のバージョン反映
pyenv global 2.7.16
rbenv global 2.6.3
phpenv global 7.3.5
nodenv global 12.3.1
goenv global 1.8.1
jenv global 12.0

# シェルの再読込
source /tmp/anyenv.setting
rm -rf /tmp/anyenv.setting
