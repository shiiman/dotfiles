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
SESSION_ID=$(echo "$input" | jq -r '.session_id // .sessionId // .session.id // .conversation_id // .conversationId // empty')
if [ -z "$SESSION_ID" ] && [ -n "${CLAUDE_SESSION_ID:-}" ]; then
    SESSION_ID="$CLAUDE_SESSION_ID"
fi
if [ -z "$SESSION_ID" ] && [ -n "$CURRENT_DIR" ]; then
    SESSION_ID="$CURRENT_DIR"
fi

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

# 経過時間表示（セッション単位）
ELAPSED_INFO=""
if [ -n "$SESSION_ID" ]; then
    STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude-statusline"
    mkdir -p "$STATE_DIR" 2>/dev/null

    SAFE_SESSION_ID=$(printf '%s' "$SESSION_ID" | tr -c 'A-Za-z0-9._-' '_')
    START_FILE="$STATE_DIR/${SAFE_SESSION_ID}.start"
    NOW_EPOCH=$(date +%s)
    START_EPOCH=""

    if [ -f "$START_FILE" ]; then
        START_EPOCH=$(head -n 1 "$START_FILE" 2>/dev/null)
    else
        printf '%s\n' "$NOW_EPOCH" > "$START_FILE" 2>/dev/null || true
        START_EPOCH="$NOW_EPOCH"
    fi

    if ! [[ "$START_EPOCH" =~ ^[0-9]+$ ]]; then
        START_EPOCH="$NOW_EPOCH"
        printf '%s\n' "$START_EPOCH" > "$START_FILE" 2>/dev/null || true
    fi

    ELAPSED_SECONDS=$((NOW_EPOCH - START_EPOCH))
    if [ "$ELAPSED_SECONDS" -lt 0 ]; then
        ELAPSED_SECONDS=0
    fi

    if [ "$ELAPSED_SECONDS" -ge 3600 ]; then
        HOURS=$((ELAPSED_SECONDS / 3600))
        MINUTES=$(((ELAPSED_SECONDS % 3600) / 60))
        ELAPSED_INFO=$(printf ' | ⏱ %dh%02dm' "$HOURS" "$MINUTES")
    elif [ "$ELAPSED_SECONDS" -ge 60 ]; then
        MINUTES=$((ELAPSED_SECONDS / 60))
        SECONDS=$((ELAPSED_SECONDS % 60))
        ELAPSED_INFO=$(printf ' | ⏱ %dm%02ds' "$MINUTES" "$SECONDS")
    else
        ELAPSED_INFO=$(printf ' | ⏱ %ds' "$ELAPSED_SECONDS")
    fi
fi

# コスト表示（0より大きい場合のみ）
COST_INFO=""
if [ "$(echo "$COST > 0" | bc -l 2>/dev/null)" = "1" ]; then
    COST_INFO=$(printf ' | 💰 $%.2f' "$COST")
fi

# 出力
# echo "[$MODEL] 📁 ${DIR_NAME}${GIT_BRANCH}${CONTEXT_INFO}${COST_INFO}"
echo "[$MODEL]${ELAPSED_INFO}${CONTEXT_INFO}${COST_INFO}"
