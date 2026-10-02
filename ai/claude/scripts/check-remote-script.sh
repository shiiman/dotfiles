#!/bin/bash
# PreToolUse の標準入力 JSON を検査する。シェル全般の安全性を保証するものではない。
set -eu

if ! command -v jq >/dev/null 2>&1; then
    echo 'コマンド検査に必要な jq が見つかりません。' >&2
    exit 2
fi

if ! command_text=$(jq -er '.tool_input.command | strings'); then
    echo 'コマンド検査の入力 JSON が不正です。' >&2
    exit 2
fi

# curl/wget からシェルへの直接パイプを拒否する（絶対パス指定も対象）。
if printf '%s\n' "$command_text" | tr '\n' ' ' | grep -Eq '(^|[[:space:];|&(/])(curl|wget)([[:space:]]|$).*\|[[:space:]]*(/[^[:space:]|;]+/)?(sh|bash|zsh)([[:space:];&]|$)'; then
    echo 'リモートスクリプトを直接シェルへ渡す実行は禁止されています。' >&2
    exit 2
fi
