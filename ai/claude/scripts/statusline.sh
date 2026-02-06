#!/bin/bash
# Claude Code カスタムステータスライン
# 標準入力からJSON形式のコンテキストを受け取り、表示内容を出力

input=$(cat)

# jqがない場合は空出力
if ! command -v jq &> /dev/null; then
    echo ""
    exit 0
fi

# 各種情報を取得
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# ホームディレクトリを~に置換して短縮
# DIR_NAME="${CURRENT_DIR/#$HOME/~}"

# Gitブランチ取得（現在のディレクトリで）
# GIT_BRANCH=""
# if [ -n "$CURRENT_DIR" ] && [ -d "$CURRENT_DIR" ]; then
#     BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
#     if [ -n "$BRANCH" ]; then
#         GIT_BRANCH=" | 🌿 $BRANCH"
#     fi
# fi

# コンテキスト使用率計算
CONTEXT_INFO=""
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
if [ "$CONTEXT_SIZE" -gt 0 ]; then
    INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
    CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
    CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
    CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
    PERCENT=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
    CONTEXT_INFO=" | 📊 ${PERCENT}%"
fi

# コスト表示（0より大きい場合のみ）
COST_INFO=""
if [ "$(echo "$COST > 0" | bc -l 2>/dev/null)" = "1" ]; then
    COST_INFO=$(printf ' | 💰 $%.2f' "$COST")
fi

# 出力
# echo "[$MODEL] 📁 ${DIR_NAME}${GIT_BRANCH}${CONTEXT_INFO}${COST_INFO}"
echo "[$MODEL] ${CONTEXT_INFO}${COST_INFO}"
