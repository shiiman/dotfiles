#!/bin/bash
# ターミナル設定セットアップスクリプト（cmux / Ghostty 共用）
set -e
set -u

DOTFILES_DIR=~/dotfiles
GHOSTTY_CONFIG_DIR=~/.config/ghostty
CMUX_CONFIG_DIR=~/.config/cmux
BACKUP_DIR=~/.terminal_backup/$(date +%Y%m%d_%H%M%S)

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
    echo "ターミナル設定セットアップ..."

    # cmuxまたはGhosttyがインストールされているか確認
    local terminal_found=false
    if [ -d "/Applications/cmux.app" ]; then
        echo "  検出: cmux"
        terminal_found=true
        create_symlink "$DOTFILES_DIR/cmux/settings.json" "$CMUX_CONFIG_DIR/settings.json"
        echo "  ✓ cmux/settings.json -> ~/.config/cmux/settings.json"
    fi
    if [ -d "/Applications/Ghostty.app" ]; then
        echo "  検出: Ghostty"
        terminal_found=true
    fi

    if [ "$terminal_found" = false ]; then
        echo "  ⚠ cmux/Ghosttyがインストールされていません（スキップ）"
        return
    fi

    # cmuxとGhosttyは同じ設定パスを使用（~/.config/ghostty/config）
    create_symlink "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
    echo "  ✓ config -> ~/.config/ghostty/config"

    # バックアップがある場合は表示
    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        echo "バックアップ先: $BACKUP_DIR"
    fi

    echo "ターミナル設定セットアップ完了"
}

main "$@"
