#!/bin/bash
set -e
set -u

# miseの初期化確認
if ! command -v mise >/dev/null 2>&1; then
    echo "mise is not installed. Please run 'brew install mise' first."
    exit 1
fi

# グローバル設定ファイルのシンボリックリンク
mkdir -p ~/.config/mise
ln -sf ~/dotfiles/mise/config.toml ~/.config/mise/config.toml

# 設定ファイルを信頼
mise trust ~/dotfiles/mise/config.toml

# miseを有効化
eval "$(mise activate bash)"

# config.toml に定義されたツールをインストール
mise install

echo ""
echo "mise setup completed!"
echo ""
echo "使い方:"
echo "  mise use node@20      # Node.js 20をインストールして使用"
echo "  mise ls               # インストール済みツール一覧"
echo "  mise ls-remote node   # 利用可能なバージョン一覧"
