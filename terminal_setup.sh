#!/bin/bash
# ターミナル設定セットアップスクリプト（cmux / Ghostty 共用）
set -e
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/symlink.sh
source "$SCRIPT_DIR/lib/symlink.sh"

DOTFILES_DIR="$HOME/dotfiles"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
CMUX_CONFIG_DIR="$HOME/.config/cmux"

# 既存の実ファイルはここへ退避してから置き換える
SYMLINK_BACKUP_DIR="$HOME/.terminal_backup/$(date +%Y%m%d_%H%M%S)"

# メイン処理
main() {
    echo "ターミナル設定セットアップ..."

    # cmuxまたはGhosttyがインストールされているか確認
    local terminal_found=false
    if [ -d "/Applications/cmux.app" ]; then
        echo "  検出: cmux"
        terminal_found=true
        create_symlink "$DOTFILES_DIR/terminal/cmux/settings.json" "$CMUX_CONFIG_DIR/settings.json"
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
    create_symlink "$DOTFILES_DIR/terminal/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
    echo "  ✓ config -> ~/.config/ghostty/config"

    print_symlink_backup_location

    echo "ターミナル設定セットアップ完了"
}

main "$@"
