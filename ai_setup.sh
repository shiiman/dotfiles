#!/bin/bash
set -e
set -u

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

    # MCP サーバー設定
    setup_claude_mcp
}

# Claude MCP サーバー設定
setup_claude_mcp() {
    echo "  MCP サーバー設定..."

    # claude コマンドの確認
    if ! command -v claude >/dev/null 2>&1; then
        echo "    ⚠ claude コマンドが見つかりません（MCP設定をスキップ）"
        return
    fi

    # uv コマンドの確認（mise_setup.sh でインストール済みの前提）
    if ! command -v uv >/dev/null 2>&1; then
        echo "    ⚠ uv コマンドが見つかりません"
        echo "      先に ./mise_setup.sh を実行してください"
        return
    fi

    # multi-agent-mcp のセットアップ
    setup_multi_agent_mcp
    setup_notebooklm_mcp
}

# multi-agent-mcp のセットアップ
setup_multi_agent_mcp() {
    local mcp_name="multi-agent-mcp"
    local mcp_repo="git+https://github.com/shiiman/multi-agent-mcp"

    # MCP 設定の追加（未設定の場合のみ）
    # uvx で GitHub から直接インストール（--refresh で毎回最新版を取得）
    if ! claude mcp list 2>/dev/null | grep -q "$mcp_name"; then
        claude mcp add --scope user "$mcp_name" -- \
            uvx --refresh --from "$mcp_repo" "$mcp_name"
        echo "    ✓ $mcp_name を Claude に追加"
    else
        echo "    ✓ $mcp_name (既に設定済み)"
    fi
}

# notebooklm-mcp のセットアップ
setup_notebooklm_mcp() {
    local mcp_name="notebooklm-mcp"
    local mcp_repo="git+https://github.com/shiiman/notebooklm-mcp"

    # MCP 設定の追加（未設定の場合のみ）
    # uvx で GitHub から直接インストール（--refresh で毎回最新版を取得）
    if ! claude mcp list 2>/dev/null | grep -q "$mcp_name"; then
        claude mcp add --scope user "$mcp_name" -- \
            uvx --refresh --from "$mcp_repo" "$mcp_name"
        echo "    ✓ $mcp_name を Claude に追加"
    else
        echo "    ✓ $mcp_name (既に設定済み)"
    fi
}

# google-genmedia-mcp のセットアップ
setup_google_genmedia_mcp() {
    local mcp_name="google-genmedia-mcp"
    local mcp_repo="git+https://github.com/shiiman/google-genmedia-mcp"

    # MCP 設定の追加（未設定の場合のみ）
    # uvx で GitHub から直接インストール（--refresh で毎回最新版を取得）
    if ! claude mcp list 2>/dev/null | grep -q "$mcp_name"; then
        claude mcp add --scope user "$mcp_name" -- \
            uvx --refresh --from "$mcp_repo" "$mcp_name"
        echo "    ✓ $mcp_name を Claude に追加"
    else
        echo "    ✓ $mcp_name (既に設定済み)"
    fi
}

# Cursor 設定
setup_cursor() {
    echo "Cursor設定..."

    # MCP設定
    create_symlink "$DOTFILES_DIR/ai/cursor/mcp.json" ~/.cursor/mcp.json
    echo "  ✓ mcp.json"

    # エディタ設定
    local cursor_user_dir="$HOME/Library/Application Support/Cursor/User"
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
    if ! command -v cursor >/dev/null 2>&1; then
        echo "  ⚠ cursor コマンドが見つかりません"
        echo "    Cursor > Command Palette > 'Install cursor command' を実行してください"
        return
    fi

    # jq コマンドの確認
    if ! command -v jq >/dev/null 2>&1; then
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

    while IFS= read -r ext_id; do
        if [[ -z "$ext_id" ]]; then
            continue
        fi
        count=$((count + 1))
        printf "    [%d/%d] %s..." "$count" "$total" "$ext_id"
        if cursor --install-extension "$ext_id" > /dev/null 2>&1; then
            echo " ✓"
        else
            echo " (スキップ)"
        fi
    done <<< "$ext_ids"

    echo "  ✓ 拡張機能インストール完了"
}

# Codex 設定
setup_codex() {
    echo "Codex設定..."

    create_symlink "$DOTFILES_DIR/ai/codex/AGENTS.md" ~/.codex/AGENTS.md
    echo "  ✓ AGENTS.md (グローバル指示)"

    create_symlink "$DOTFILES_DIR/ai/codex/config.toml" ~/.codex/config.toml
    echo "  ✓ config.toml"

    create_symlink "$DOTFILES_DIR/ai/codex/skills" ~/.codex/skills
    echo "  ✓ skills/ (スキル定義)"

    # 共有ライブラリ
    create_symlink "$DOTFILES_DIR/ai/codex/lib" ~/.codex/lib
    echo "  ✓ lib/ (共有ライブラリ)"

    # agents ディレクトリを丸ごとリンク（新規 .toml 追加も自動反映）
    local agent_dir="$DOTFILES_DIR/ai/codex/agents"
    if [ -d "$agent_dir" ]; then
        create_symlink "$agent_dir" ~/.codex/agents
        echo "  ✓ agents/ (agents定義)"
    else
        echo "  ⚠ ai/codex/agents/ ディレクトリが見つかりません（スキップ）"
    fi
}

# Antigravity 設定
setup_antigravity() {
    echo "Antigravity設定..."

    create_symlink "$DOTFILES_DIR/ai/antigravity/GEMINI.md" ~/.gemini/GEMINI.md
    echo "  ✓ GEMINI.md (グローバル指示)"

    create_symlink "$DOTFILES_DIR/ai/antigravity/extensions.json" ~/.antigravity/extensions/extensions.json
    echo "  ✓ extensions.json (拡張機能リスト)"

    install_antigravity_extensions
}

# Antigravity 拡張機能インストール
install_antigravity_extensions() {
    local ext_file="$DOTFILES_DIR/ai/antigravity/extensions.json"
    if [[ ! -f "$ext_file" ]]; then
        echo "  ⚠ extensions.json が見つかりません"
        return
    fi

    local antigravity_cmd=""
    if command -v antigravity >/dev/null 2>&1; then
        antigravity_cmd="antigravity"
    elif command -v agy >/dev/null 2>&1; then
        antigravity_cmd="agy"
    else
        echo "  ⚠ Antigravity のコマンドラインツールが見つかりません"
        echo "    Antigravity 側で CLI をインストールしてください"
        return
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "  ⚠ jq コマンドが見つかりません（拡張機能インストールをスキップ）"
        return
    fi

    echo "  拡張機能インストール中..."

    local ext_ids
    ext_ids=$(jq -r '.[].identifier.id' "$ext_file")

    local count=0
    local total
    total=$(echo "$ext_ids" | wc -l | tr -d ' ')

    while IFS= read -r ext_id; do
        if [[ -z "$ext_id" ]]; then
            continue
        fi
        count=$((count + 1))
        printf "    [%d/%d] %s..." "$count" "$total" "$ext_id"
        if "$antigravity_cmd" --install-extension "$ext_id" > /dev/null 2>&1; then
            echo " ✓"
        else
            echo " (スキップ)"
        fi
    done <<< "$ext_ids"

    echo "  ✓ 拡張機能インストール完了"
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

    setup_antigravity
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
