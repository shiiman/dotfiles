#!/bin/bash
# ドットファイルのシンボリックリンクを作成する
set -e
set -u

DOTFILES_DIR="$HOME/dotfiles"

# 通常のドットファイルを定義.
DOT_FILES=(.bashrc .zshrc .shellrc_common .gitconfig .gitignore_global .tmux.conf .vimrc)

# ローカル設定（追跡対象外）を雛形から用意する.
# ~/.gitconfig をシンボリックリンクに置き換える前に呼ぶ必要がある
# （既存の user.name / user.email を読み取って引き継ぐため）.
setup_local_configs() {
    local name=""
    local email=""

    # git のユーザー情報: ~/.gitconfig.local
    # .gitconfig は公開リポジトリに含まれるため、identity はここへ分離する
    if [ -f "$HOME/.gitconfig.local" ]; then
        echo "  - ~/.gitconfig.local (既存のため変更しない)"
    else
        # 既存設定があれば引き継ぐ（無ければ空のまま雛形を出力）
        name=$(git config --global user.name 2>/dev/null || true)
        email=$(git config --global user.email 2>/dev/null || true)

        if [ -n "$name" ] || [ -n "$email" ]; then
            {
                echo "[user]"
                echo "	name = $name"
                echo "	email = $email"
            } >"$HOME/.gitconfig.local"
            echo "  ✓ ~/.gitconfig.local を作成（既存の user.name / user.email を引き継ぎ）"
        else
            cp "$DOTFILES_DIR/.gitconfig.local.example" "$HOME/.gitconfig.local"
            echo "  ⚠ ~/.gitconfig.local を雛形から作成しました。name / email を編集してください"
        fi
    fi

    # 環境固有のシェル設定: ~/.shellrc_local
    if [ -f "$HOME/.shellrc_local" ]; then
        echo "  - ~/.shellrc_local (既存のため変更しない)"
    else
        cp "$DOTFILES_DIR/.shellrc_local.example" "$HOME/.shellrc_local"
        echo "  ✓ ~/.shellrc_local を雛形から作成"
    fi
}

# ホームディレクトリ配下にシンボリックリンクをはる.
setup_symlinks() {
    local missing=0
    local file

    for file in "${DOT_FILES[@]}"; do
        # リンク元が無い場合は壊れたリンクを作らずに警告する
        if [ ! -e "$DOTFILES_DIR/$file" ]; then
            echo "  ⚠ $file がリポジトリに存在しないためスキップ" >&2
            missing=$((missing + 1))
            continue
        fi

        ln -sfn "$DOTFILES_DIR/$file" "$HOME/$file"
        echo "  ✓ $file -> ~/$file"
    done

    if [ "$missing" -gt 0 ]; then
        echo "" >&2
        echo "⚠ $missing 件のリンクを作成できませんでした（DOT_FILES の定義を確認してください）" >&2
        return 1
    fi
}

main() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo "エラー: $DOTFILES_DIR が見つかりません" >&2
        exit 1
    fi

    echo "ローカル設定の準備..."
    setup_local_configs

    echo ""
    echo "シンボリックリンクの作成..."
    setup_symlinks

    echo ""
    echo "dotfile setup completed!"
}

main "$@"
