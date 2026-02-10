#!/usr/bin/env bash
set -euo pipefail

BOT_TOKEN="${TG_BOT_TOKEN:-}"
CHAT_ID="${TG_CHAT_ID:-}"

if [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]]; then
  exit 0
fi

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // "unknown"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // ""')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

PROJECT_NAME=$(basename "$CWD")
SHORT_SESSION="${SESSION_ID:0:8}"

MAX_CLAUDE_MSG=1000

reverse_file() {
  if command -v tac >/dev/null 2>&1; then
    tac "$1"
  else
    tail -r "$1"
  fi
}

CLAUDE_MESSAGE=""
if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
  LAST_ASSISTANT=$(reverse_file "$TRANSCRIPT_PATH" | jq -c 'select(.type == "assistant")' 2>/dev/null | head -1 || true)
  if [[ -n "$LAST_ASSISTANT" ]]; then
    CLAUDE_MESSAGE=$(echo "$LAST_ASSISTANT" \
      | jq -r '.message.content[]? | select(.type == "text") | .text' 2>/dev/null \
      | head -c "$MAX_CLAUDE_MSG" || true)
  fi
fi

case "$NOTIFICATION_TYPE" in
  idle_prompt)
    TEXT="Claude Code waiting for input
Project: ${PROJECT_NAME}
Session: ${SHORT_SESSION}"
    if [[ -n "$CLAUDE_MESSAGE" ]]; then
      TEXT="${TEXT}

${CLAUDE_MESSAGE}"
    fi
    ;;
  permission_prompt)
    SAFE_MESSAGE=$(echo "$MESSAGE" | head -c 300)
    TEXT="Permission required
Project: ${PROJECT_NAME}
Session: ${SHORT_SESSION}

${SAFE_MESSAGE}"
    if [[ -n "$CLAUDE_MESSAGE" ]]; then
      TEXT="${TEXT}

Claude said:
${CLAUDE_MESSAGE}"
    fi
    ;;
  *)
    TEXT="Claude Code: ${MESSAGE}"
    if [[ -n "$CLAUDE_MESSAGE" ]]; then
      TEXT="${TEXT}

${CLAUDE_MESSAGE}"
    fi
    ;;
esac

JSON=$(jq -nc --arg chat_id "$CHAT_ID" --arg text "$TEXT" '{chat_id: $chat_id, text: $text}')

curl -s -X POST \
  "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -H "Content-Type: application/json" \
  -d "$JSON" > /dev/null 2>&1 &

exit 0
