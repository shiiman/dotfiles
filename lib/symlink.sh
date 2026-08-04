#!/bin/bash
# シンボリックリンク作成の共通処理
#
# dotfile_setup.sh / terminal_setup.sh / ai_setup.sh から source して使う。
# 以前は3スクリプトが個別に実装しており、バックアップの有無や挙動が揃っていなかった。
#
# 使い方:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/lib/symlink.sh"
#
#   # 既存ファイルをバックアップしたい場合は先に設定する（未設定ならバックアップしない）
#   SYMLINK_BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
#
#   create_symlink "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"

# バックアップ先。未設定なら既存ファイルはバックアップせずに置き換える。
: "${SYMLINK_BACKUP_DIR:=}"

# create_symlink <リンク元> <リンク先>
#
# - リンク元が存在しない場合は警告して 1 を返す（壊れたリンクを作らない）
# - リンク先が既存の symlink なら解除、実ファイル／ディレクトリなら
#   SYMLINK_BACKUP_DIR が設定されていればバックアップしてから置き換える
create_symlink() {
    local src="$1"
    local dest="$2"
    local dest_dir

    if [ -z "$src" ] || [ -z "$dest" ]; then
        echo "  ⚠ create_symlink: リンク元またはリンク先が空です" >&2
        return 1
    fi

    if [ ! -e "$src" ]; then
        echo "  ⚠ $src が存在しないためスキップ" >&2
        return 1
    fi

    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"

    if [ -L "$dest" ]; then
        # 既存のシンボリックリンクは解除するだけ（実体には触れない）
        unlink "$dest"
    elif [ -e "$dest" ]; then
        if [ -n "$SYMLINK_BACKUP_DIR" ]; then
            mkdir -p "$SYMLINK_BACKUP_DIR"
            cp -R "$dest" "$SYMLINK_BACKUP_DIR/$(basename "$dest")"
            echo "  バックアップ: $dest -> $SYMLINK_BACKUP_DIR/"
        fi
        rm -rf "$dest"
    fi

    ln -sfn "$src" "$dest"
}

# バックアップを作成した場合にその場所を表示する
print_symlink_backup_location() {
    if [ -n "$SYMLINK_BACKUP_DIR" ] && [ -d "$SYMLINK_BACKUP_DIR" ]; then
        echo ""
        echo "バックアップ先: $SYMLINK_BACKUP_DIR"
    fi
}
