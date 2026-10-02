#!/bin/bash
# 明示的に実行した場合のみ、有効なプラグインを順番に更新する。
set -eu

SETTINGS="${CLAUDE_SETTINGS_FILE:-$HOME/.claude/settings.json}"
for required_command in jq claude; do
    if ! command -v "$required_command" >/dev/null 2>&1; then
        echo "必要なコマンドが見つかりません: $required_command" >&2
        exit 1
    fi
done

if [ ! -f "$SETTINGS" ]; then
    echo 'Claude の設定ファイルが見つかりません。' >&2
    exit 1
fi

PLUGINS=$(jq -er '.enabledPlugins // {} | to_entries | map(select(.value == true) | .key) | join("\n")' "$SETTINGS")
if [ -z "$PLUGINS" ]; then
    echo '更新対象のプラグインはありません。'
    exit 0
fi

failed=0
while IFS= read -r plugin; do
    if ! claude plugin update "$plugin"; then
        echo "プラグインの更新に失敗しました: $plugin" >&2
        failed=1
    fi
done <<< "$PLUGINS"
exit "$failed"
