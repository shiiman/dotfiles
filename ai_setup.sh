#!/bin/bash
set -e

DOTFILES_DIR=~/dotfiles

# バックアップディレクトリ（日時付き）
BACKUP_DIR=~/.ai_config_backup/$(date +%Y%m%d_%H%M%S)

# 既存ファイルをバックアップしてからシンボリックリンクを作成
create_symlink() {
    local src=$1
    local dest=$2
    local dest_dir
    dest_dir=$(dirname "$dest")

    # 親ディレクトリ作成
    mkdir -p "$dest_dir"

    # 既存のファイル/リンクを処理
    if [ -L "$dest" ]; then
        # シンボリックリンクの場合は削除のみ
        unlink "$dest"
    elif [ -e "$dest" ]; then
        # 実ファイルの場合はバックアップしてから削除
        mkdir -p "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$(basename "$dest")"
        echo "  バックアップ: $dest -> $backup_path"
        cp -r "$dest" "$backup_path"
        rm -rf "$dest"
    fi

    # シンボリックリンク作成
    ln -sf "$src" "$dest"
}

# Claude Code グローバル設定
setup_claude() {
    echo "Claude Code設定..."

    create_symlink "$DOTFILES_DIR/ai/claude/settings.json" ~/.claude/settings.json
    echo "  ✓ settings.json"

    create_symlink "$DOTFILES_DIR/ai/claude/CLAUDE.md" ~/.claude/CLAUDE.md
    echo "  ✓ CLAUDE.md (グローバル指示)"
}

# Cursor 設定
setup_cursor() {
    echo "Cursor設定..."

    # MCP設定
    create_symlink "$DOTFILES_DIR/ai/cursor/mcp.json" ~/.cursor/mcp.json
    echo "  ✓ mcp.json"

    # エディタ設定
    local cursor_user_dir=~/Library/Application\ Support/Cursor/User
    if [ -d "$cursor_user_dir" ] || [ -L "$cursor_user_dir" ]; then
        create_symlink "$DOTFILES_DIR/ai/cursor/User/settings.json" "$cursor_user_dir/settings.json"
        echo "  ✓ User/settings.json (エディタ設定)"

        create_symlink "$DOTFILES_DIR/ai/cursor/User/keybindings.json" "$cursor_user_dir/keybindings.json"
        echo "  ✓ User/keybindings.json (キーバインド)"

        create_symlink "$DOTFILES_DIR/ai/cursor/User/snippets" "$cursor_user_dir/snippets"
        echo "  ✓ User/snippets/ (スニペット)"
    else
        echo "  ⚠ Cursorがインストールされていないため、エディタ設定はスキップ"
    fi

    # 拡張機能リスト
    create_symlink "$DOTFILES_DIR/ai/cursor/extensions.json" ~/.cursor/extensions/extensions.json
    echo "  ✓ extensions.json (拡張機能リスト)"

    # 拡張機能インストール
    install_cursor_extensions
}

# Cursor 拡張機能インストール
install_cursor_extensions() {
    local ext_file="$DOTFILES_DIR/ai/cursor/extensions.json"
    if [ ! -f "$ext_file" ]; then
        echo "  ⚠ extensions.json が見つかりません"
        return
    fi

    # cursor コマンドの確認
    if ! command -v cursor &> /dev/null; then
        echo "  ⚠ cursor コマンドが見つかりません"
        echo "    Cursor > Command Palette > 'Install cursor command' を実行してください"
        return
    fi

    # jq コマンドの確認
    if ! command -v jq &> /dev/null; then
        echo "  ⚠ jq コマンドが見つかりません（拡張機能インストールをスキップ）"
        return
    fi

    echo "  拡張機能インストール中..."

    # extensions.jsonから拡張機能IDを抽出してインストール
    local ext_ids
    ext_ids=$(jq -r '.[].identifier.id' "$ext_file")

    local count=0
    local total
    total=$(echo "$ext_ids" | wc -l | tr -d ' ')

    for ext_id in $ext_ids; do
        ((count++))
        printf "    [%d/%d] %s..." "$count" "$total" "$ext_id"
        if cursor --install-extension "$ext_id" > /dev/null 2>&1; then
            echo " ✓"
        else
            echo " (スキップ)"
        fi
    done

    echo "  ✓ 拡張機能インストール完了"
}

# Codex 設定
setup_codex() {
    echo "Codex設定..."

    create_symlink "$DOTFILES_DIR/ai/codex/config.toml" ~/.codex/config.toml
    echo "  ✓ config.toml"

    create_symlink "$DOTFILES_DIR/ai/codex/skills" ~/.codex/skills
    echo "  ✓ skills/ (スキル定義)"
}

# メイン処理
main() {
    echo "=========================================="
    echo "AIツール設定セットアップ"
    echo "=========================================="
    echo ""

    setup_claude
    echo ""

    setup_cursor
    echo ""

    setup_codex
    echo ""

    echo "=========================================="
    echo "完了"
    echo "=========================================="

    # バックアップがある場合は表示
    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        echo "バックアップ先: $BACKUP_DIR"
    fi
}

main "$@"
