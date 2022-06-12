#!/bin/bash

# anyenvのインストール.
if [ ! -e ~/.anyenv ]; then
    git clone https://github.com/anyenv/anyenv ~/.anyenv
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

anyenv install phpenv
anyenv install rbenv
anyenv install nodenv
anyenv install goenv

# シェルの再読込
source /tmp/anyenv.setting

# macOS SDK header install
if [[ `sw_vers` == *"10.14."* ]] ; then
  sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
fi

# 各言語をインストール
PHP_BUILD_CONFIGURE_OPTS="--disable-fpm \
                          --disable-phpdbg \
                          --enable-debug \
                          --with-openssl=$(brew --prefix openssl) \
                          --with-bz2=$(brew --prefix bzip2) \
                          --with-iconv=$(brew --prefix libiconv) \
                          --with-icu-dir=$(brew --prefix icu4c) \
                          --with-tidy=$(brew --prefix tidy-html5) \
                          --with-libzip=$(brew --prefix libzip) \
                          --with-libxml-dir=$(brew --prefix libxml2) \
                          --with-zlib \
                          --with-zlib-dir=$(brew --prefix zlib) \
                          --with-libedit=$(brew --prefix libedit) \
                          --with-external-pcre=$(brew --prefix pcre2)" \
PHP_BUILD_EXTRA_MAKE_ARGUMENTS="-j$(sysctl -n hw.logicalcpu_max)" \
phpenv install --ini development 8.1.7
rbenv install 3.1.2
nodenv install 18.3.0
goenv install 1.18.0

# 各言語のバージョン反映
phpenv global 8.1.7
rbenv global 3.1.2
nodenv global 18.3.0
goenv global 1.18.0

# シェルの再読込
source /tmp/anyenv.setting
rm -rf /tmp/anyenv.setting

# ==============================================================

## VScodeのphp debugを利用するためにはphp.iniに下記の設定が必要
## php.iniのpath $HOME/.anyenv/envs/phpenv/versions/${php_version}/etc/conf.d

# xdebug.remote_enable = 1
# xdebug.remote_autostart = 1

# ==============================================================
