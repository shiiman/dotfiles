#!/bin/bash
# Ghosttyセットアップスクリプト
set -e
set -u

DOTFILES_DIR=~/dotfiles
GHOSTTY_CONFIG_DIR=~/.config/ghostty
BACKUP_DIR=~/.ghostty_backup/$(date +%Y%m%d_%H%M%S)

# バックアップしてからシンボリックリンクを作成
create_symlink() {
    local src=$1
    local dest=$2
    local dest_dir
    dest_dir=$(dirname "$dest")

    # 親ディレクトリ作成
    mkdir -p "$dest_dir"

    # 既存のファイル/リンクを処理
    if [ -L "$dest" ]; then
        unlink "$dest"
    elif [ -e "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$dest" "$BACKUP_DIR/"
        echo "  バックアップ: $dest -> $BACKUP_DIR/"
        rm -rf "$dest"
    fi

    ln -sf "$src" "$dest"
}

# メイン処理
main() {
    echo "Ghostty設定セットアップ..."

    # Ghosttyがインストールされているか確認
    if [ ! -d "/Applications/Ghostty.app" ]; then
        echo "  ⚠ Ghosttyがインストールされていません（スキップ）"
        return
    fi

    create_symlink "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
    echo "  ✓ config"

    # バックアップがある場合は表示
    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        echo "バックアップ先: $BACKUP_DIR"
    fi

    echo "Ghostty設定セットアップ完了"
}

main "$@"
