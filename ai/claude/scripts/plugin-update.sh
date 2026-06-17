#!/bin/bash
# Claude Code プラグイン自動更新スクリプト
# SessionStart フックから呼び出され、有効なプラグインを全て更新する

SETTINGS="$HOME/.claude/settings.json"

if ! command -v jq &>/dev/null; then
    exit 0
fi

if [ ! -f "$SETTINGS" ]; then
    exit 0
fi

# enabledPlugins から true のものを全て取得
PLUGINS=$(jq -r '.enabledPlugins | to_entries[] | select(.value == true) | .key' "$SETTINGS" 2>/dev/null)

if [ -z "$PLUGINS" ]; then
    exit 0
fi

while IFS= read -r plugin; do
    claude plugin update "$plugin" 2>/dev/null || true
done <<< "$PLUGINS"
