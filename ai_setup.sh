#!/bin/bash
set -e
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/symlink.sh
source "$SCRIPT_DIR/lib/symlink.sh"

DOTFILES_DIR="$HOME/dotfiles"

# 既存の実ファイルはここへ退避してから置き換える
SYMLINK_BACKUP_DIR="$HOME/.ai_config_backup/$(date +%Y%m%d_%H%M%S)"

# Claude Code グローバル設定
setup_claude() {
    echo "Claude Code設定..."

    create_symlink "$DOTFILES_DIR/ai/claude/settings.json" ~/.claude/settings.json
    echo "  ✓ settings.json"

    create_symlink "$DOTFILES_DIR/ai/claude/CLAUDE.md" ~/.claude/CLAUDE.md
    echo "  ✓ CLAUDE.md (グローバル指示)"

    # プラグイン設定
    setup_claude_plugins

    # MCP サーバー設定
    setup_claude_mcp
}

# Claude Code プラグイン設定
setup_claude_plugins() {
    echo "  プラグイン設定..."

    # claude コマンドの確認
    if ! command -v claude >/dev/null 2>&1; then
        echo "    ⚠ claude コマンドが見つかりません（プラグイン設定をスキップ）"
        return
    fi

    setup_shiiman_claude_code_plugins
    setup_codex_plugin_cc
    setup_superpowers
}

# shiiman-claude-code-plugins のセットアップ
setup_shiiman_claude_code_plugins() {
    local marketplace="shiiman-claude-code-plugins"
    local marketplace_repo="shiiman/claude-code-plugins"
    local plugins=(
        "shiiman-common"
        "shiiman-claude"
        "shiiman-git"
        "shiiman-github"
        "shiiman-go"
        "shiiman-terraform"
        "shiiman-workflow"
        "shiiman-google"
        "shiiman-slack"
    )

    # マーケットプレイスの追加（未設定の場合のみ）
    if ! claude plugin marketplace list 2>/dev/null | grep -q "$marketplace"; then
        claude plugin marketplace add "$marketplace_repo"
        echo "    ✓ $marketplace マーケットプレイスを追加"
    else
        echo "    ✓ $marketplace (マーケットプレイス設定済み)"
    fi

    # 各プラグインのインストール（未インストールの場合のみ）
    for plugin_name in "${plugins[@]}"; do
        local plugin="${plugin_name}@${marketplace}"
        if ! claude plugin list 2>/dev/null | grep -q "$plugin"; then
            claude plugin install --scope user "$plugin"
            echo "    ✓ $plugin をインストール"
        else
            echo "    ✓ $plugin (インストール済み)"
        fi
    done
}

# codex-plugin-cc のセットアップ
setup_codex_plugin_cc() {
    local marketplace="openai-codex"
    local plugin="codex@openai-codex"
    local marketplace_repo="openai/codex-plugin-cc"

    # マーケットプレイスの追加（未設定の場合のみ）
    if ! claude plugin marketplace list 2>/dev/null | grep -q "$marketplace"; then
        claude plugin marketplace add "$marketplace_repo"
        echo "    ✓ $marketplace マーケットプレイスを追加"
    else
        echo "    ✓ $marketplace (マーケットプレイス設定済み)"
    fi

    # プラグインのインストール（未インストールの場合のみ）
    if ! claude plugin list 2>/dev/null | grep -q "$plugin"; then
        claude plugin install --scope user "$plugin"
        echo "    ✓ $plugin をインストール"
    else
        echo "    ✓ $plugin (インストール済み)"
    fi
}

# superpowers のセットアップ
setup_superpowers() {
    local marketplace="superpowers-marketplace"
    local plugin="superpowers@superpowers-marketplace"
    local marketplace_repo="obra/superpowers-marketplace"

    # マーケットプレイスの追加（未設定の場合のみ）
    if ! claude plugin marketplace list 2>/dev/null | grep -q "$marketplace"; then
        claude plugin marketplace add "$marketplace_repo"
        echo "    ✓ $marketplace マーケットプレイスを追加"
    else
        echo "    ✓ $marketplace (マーケットプレイス設定済み)"
    fi

    # プラグインのインストール（未インストールの場合のみ）
    if ! claude plugin list 2>/dev/null | grep -q "$plugin"; then
        claude plugin install --scope user "$plugin"
        echo "    ✓ $plugin をインストール"
    else
        echo "    ✓ $plugin (インストール済み)"
    fi
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

    # 拡張機能（extensions.json は Cursor 自身が書き換えるため管理しない）
    restore_extensions_json ~/.cursor/extensions/extensions.json

    if command -v cursor >/dev/null 2>&1; then
        install_extensions_from_list cursor "$DOTFILES_DIR/ai/cursor/extensions.txt"
    else
        echo "  ⚠ cursor コマンドが見つかりません（拡張機能インストールをスキップ）"
        echo "    Cursor > Command Palette > 'Install cursor command' を実行してください"
    fi
}

# 旧方式（extensions.json を dotfiles から symlink）を解除する
#
# extensions.json はエディタが拡張の追加・削除時に書き換える内部管理ファイルで、
# インストール先の絶対パスやタイムスタンプを含む。symlink にするとそれらが
# リポジトリへ流入するため、追跡は extensions.txt（ID リスト）に切り替えた。
restore_extensions_json() {
    local dest="$1"
    local target=""

    if [ ! -L "$dest" ]; then
        return
    fi

    target="$(readlink "$dest")"
    unlink "$dest"
    if [ -f "$target" ]; then
        # 現在の内容を実ファイルとして残し、エディタの管理下に戻す
        cp "$target" "$dest"
    fi
    echo "  ✓ extensions.json の symlink を解除（エディタ管理に戻した）"
}

# 拡張機能を ID リスト（1行1ID）からインストールする
# $1: エディタの CLI コマンド, $2: ID リストのパス
install_extensions_from_list() {
    local cmd="$1"
    local ext_file="$2"
    local count=0
    local total=0
    local ext_id

    if [ ! -f "$ext_file" ]; then
        echo "  ⚠ $(basename "$ext_file") が見つかりません（拡張機能インストールをスキップ）"
        return
    fi

    total="$(grep -cve '^[[:space:]]*$' "$ext_file" || true)"
    echo "  拡張機能インストール中... ($total 件)"

    while IFS= read -r ext_id; do
        # 空行とコメント行を読み飛ばす
        case "$ext_id" in
            "" | \#*) continue ;;
        esac
        count=$((count + 1))
        printf "    [%d/%d] %s..." "$count" "$total" "$ext_id"
        if "$cmd" --install-extension "$ext_id" >/dev/null 2>&1; then
            echo " ✓"
        else
            echo " (スキップ)"
        fi
    done <"$ext_file"

    echo "  ✓ 拡張機能インストール完了"
}

# VSCode 設定
#
# 拡張機能は Brewfile の vscode "..." で管理する（extensions.json は
# 絶対パスやタイムスタンプを含む自動生成ファイルなので追跡しない）。
setup_vscode() {
    echo "VSCode設定..."

    local vscode_user_dir="$HOME/Library/Application Support/Code/User"

    if [ ! -d "$vscode_user_dir" ] && [ ! -L "$vscode_user_dir" ]; then
        echo "  ⚠ VSCodeがインストールされていないためスキップ"
        return
    fi

    create_symlink "$DOTFILES_DIR/ai/vscode/User/settings.json" "$vscode_user_dir/settings.json"
    echo "  ✓ User/settings.json (エディタ設定)"

    create_symlink "$DOTFILES_DIR/ai/vscode/User/keybindings.json" "$vscode_user_dir/keybindings.json"
    echo "  ✓ User/keybindings.json (キーバインド)"
}

# Codex の config.toml をテンプレートから用意する
#
# Codex CLI 自身が起動時・操作時に以下を自動追記・更新するため、symlink にすると
# マシン固有の絶対パスや社内プロジェクト名がリポジトリへ流入し、作業ツリーも常に dirty になる。
#   [projects."<絶対パス>"] / [hooks.state."<絶対パス>:..."] / [marketplaces.*] など
# そのため追跡するのは config.toml.template のみとし、実ファイルはコピーで用意する。
setup_codex_config() {
    local template="$DOTFILES_DIR/ai/codex/config.toml.template"
    local dest="$HOME/.codex/config.toml"
    local link_target=""

    if [ ! -f "$template" ]; then
        echo "  ⚠ ai/codex/config.toml.template が見つかりません（スキップ）"
        return
    fi

    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ]; then
        # 旧方式（dotfiles への symlink）からの移行。
        # リンク先の内容をコピーして trust 設定などを失わせない。
        link_target=$(readlink "$dest")
        unlink "$dest"
        if [ -f "$link_target" ]; then
            cp "$link_target" "$dest"
            echo "  ✓ config.toml (symlink を実ファイル化し既存設定を引き継ぎ)"
        else
            cp "$template" "$dest"
            echo "  ✓ config.toml (テンプレートから作成)"
        fi
    elif [ -f "$dest" ]; then
        echo "  - config.toml (既存のため変更しない)"
        echo "    ※ 設定変更を dotfiles に反映する場合は config.toml.template を更新"
    else
        cp "$template" "$dest"
        echo "  ✓ config.toml (テンプレートから作成)"
    fi
}

# Codex 設定
setup_codex() {
    echo "Codex設定..."

    create_symlink "$DOTFILES_DIR/ai/codex/AGENTS.md" ~/.codex/AGENTS.md
    echo "  ✓ AGENTS.md (グローバル指示)"

    setup_codex_config

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

    # プラグイン設定
    setup_codex_plugins
}

# Codex プラグイン設定
setup_codex_plugins() {
    echo "  プラグイン設定..."

    # codex コマンドの確認
    if ! command -v codex >/dev/null 2>&1; then
        echo "    ⚠ codex コマンドが見つかりません（プラグイン設定をスキップ）"
        return
    fi

    setup_codex_superpowers
}

# Codex superpowers のセットアップ
setup_codex_superpowers() {
    local marketplace="superpowers-marketplace"
    local plugin="superpowers@superpowers-marketplace"
    local marketplace_repo="obra/superpowers-marketplace"

    # マーケットプレイスの追加（未設定の場合のみ）
    if ! codex plugin marketplace list 2>/dev/null | grep -q "$marketplace"; then
        codex plugin marketplace add "$marketplace_repo"
        echo "    ✓ $marketplace マーケットプレイスを追加"
    else
        echo "    ✓ $marketplace (マーケットプレイス設定済み)"
    fi

    # プラグインのインストール（未インストールの場合のみ）
    if ! codex plugin list 2>/dev/null | grep -F "$plugin" | grep -q "installed"; then
        codex plugin add "$plugin"
        echo "    ✓ $plugin をインストール"
    else
        echo "    ✓ $plugin (インストール済み)"
    fi
}

# Antigravity 設定
setup_antigravity() {
    echo "Antigravity設定..."

    create_symlink "$DOTFILES_DIR/ai/antigravity/GEMINI.md" ~/.gemini/GEMINI.md
    echo "  ✓ GEMINI.md (グローバル指示)"

    # 拡張機能（extensions.json は Antigravity 自身が書き換えるため管理しない）
    restore_extensions_json ~/.antigravity/extensions/extensions.json

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

    install_extensions_from_list "$antigravity_cmd" "$DOTFILES_DIR/ai/antigravity/extensions.txt"
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

    setup_vscode
    echo ""

    setup_codex
    echo ""

    setup_antigravity
    echo ""

    echo "=========================================="
    echo "完了"
    echo "=========================================="

    print_symlink_backup_location
}

main "$@"
