# Claude Code Telegram Notifications

Simple one-way notifications from Claude Code to Telegram. Get notified when Claude Code:
- Finishes work and waits for your input
- Needs permission to run a tool

## How it works

A single shell script runs as a [Claude Code hook](https://docs.anthropic.com/en/docs/claude-code/hooks). When Claude Code triggers `idle_prompt` or `permission_prompt`, the script sends a message to your Telegram bot.

```
Claude Code (idle/permission) --> hook --> Telegram Bot --> your phone
```

## Setup

### 1. Create a Telegram bot

1. Open Telegram, find [@BotFather](https://t.me/BotFather)
2. Send `/newbot`, pick a name and username
3. Copy the bot token

### 2. Get your chat ID

1. Send any message to your new bot
2. Open `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates`
3. Find `"chat":{"id": YOUR_CHAT_ID}` in the response

### 3. Configure environment variables

Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "TG_BOT_TOKEN": "your-bot-token",
    "TG_CHAT_ID": "your-chat-id"
  }
}
```

Or export in your shell profile (`~/.zshrc` / `~/.bashrc`):

```bash
export TG_BOT_TOKEN="your-bot-token"
export TG_CHAT_ID="your-chat-id"
```

### 4. Add the hook

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "idle_prompt|permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/claude-telegram-bridge/hooks/scripts/notify.sh",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

Replace `/path/to/` with the actual path where you cloned the repo.

## Notification examples

**Idle prompt:**
```
Claude Code waiting for input
Project: my-project
Session: a1b2c3d4
```

**Permission prompt:**
```
Permission required
Project: my-project
Session: a1b2c3d4

Claude wants to use Bash: npm install
```

## Requirements

- `jq` and `curl` (pre-installed on macOS and most Linux distros)

## License

MIT
