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

PROJECT_NAME=$(basename "$CWD")
SHORT_SESSION="${SESSION_ID:0:8}"

case "$NOTIFICATION_TYPE" in
  idle_prompt)
    TEXT="Claude Code waiting for input
Project: ${PROJECT_NAME}
Session: ${SHORT_SESSION}"
    ;;
  permission_prompt)
    SAFE_MESSAGE=$(echo "$MESSAGE" | head -c 300)
    TEXT="Permission required
Project: ${PROJECT_NAME}
Session: ${SHORT_SESSION}

${SAFE_MESSAGE}"
    ;;
  *)
    TEXT="Claude Code: ${MESSAGE}"
    ;;
esac

JSON=$(jq -nc --arg chat_id "$CHAT_ID" --arg text "$TEXT" '{chat_id: $chat_id, text: $text}')

curl -s -X POST \
  "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -H "Content-Type: application/json" \
  -d "$JSON" > /dev/null 2>&1 &

exit 0
