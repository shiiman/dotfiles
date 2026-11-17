#!/bin/bash
set -eu

# 配置先のリンクから実体をたどり、共通のリンク作成処理を使う。
script_path="${BASH_SOURCE[0]}"
while [ -L "$script_path" ]; do
    script_dir="$(cd "$(dirname "$script_path")" && pwd)"
    link_target="$(readlink "$script_path")"
    case "$link_target" in
        /*) script_path="$link_target" ;;
        *) script_path="$script_dir/$link_target" ;;
    esac
done
script_dir="$(cd "$(dirname "$script_path")" && pwd)"
dotfiles_dir="$(cd "$script_dir/../.." && pwd)"
# shellcheck source=../../lib/symlink.sh
source "$dotfiles_dir/lib/symlink.sh"

skill_dir="$script_dir/skills/yomiyasu"
# 検証時だけ、一時ディレクトリを利用できる。
user_dir="${YOMIYASU_USER_DIR:-$HOME}"
destinations=("$user_dir/.claude/skills/yomiyasu" "$user_dir/.codex/skills/yomiyasu")

check_destinations() {
    local dest
    for dest in "${destinations[@]}"; do
        if [ -L "$dest" ]; then
            if [ "$(readlink "$dest")" != "$skill_dir" ]; then
                echo "別のスキルへのリンクがあるため変更しません: $dest" >&2
                return 1
            fi
        elif [ -e "$dest" ]; then
            echo "既存のファイルがあるため変更しません: $dest" >&2
            return 1
        fi
    done
}

show_status() {
    local dest label state
    for dest in "${destinations[@]}"; do
        case "$dest" in
            */.claude/*) label="Claude Code" ;;
            *) label="Codex" ;;
        esac
        state="OFF"
        if [ -f "$dest/SKILL.md" ]; then
            state="ON"
        elif [ -L "$dest" ]; then
            state="リンク切れ"
        fi
        echo "$label: $state"
    done
}

case "${1:-status}" in
    on)
        if [ ! -f "$skill_dir/SKILL.md" ]; then
            echo "yomiyasu 本体がありません。README.md の導入手順を確認してください。" >&2
            exit 1
        fi
        check_destinations
        for dest in "${destinations[@]}"; do
            create_symlink "$skill_dir" "$dest"
        done
        show_status
        echo "次の新しいチャットから自動適用されます。"
        ;;
    off)
        check_destinations
        for dest in "${destinations[@]}"; do
            if [ -L "$dest" ]; then
                unlink "$dest"
            fi
        done
        show_status
        echo "素の出力を比較するときは、新しいチャットを開いてください。"
        ;;
    status) show_status ;;
    *)
        echo "使い方: yomiyasu [on|off|status]" >&2
        exit 2
        ;;
esac
