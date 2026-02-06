# Claude Code Telegram Notifications

Get notified in Telegram when Claude Code finishes work or needs permission.

```
Claude Code --> hook --> Telegram Bot --> your phone
```

## Installation

### 1. Create a Telegram bot

- Open [@BotFather](https://t.me/BotFather), send `/newbot`
- Copy the bot token
- Send any message to your bot, then open `https://api.telegram.org/bot<TOKEN>/getUpdates` to get your chat ID

### 2. Install the plugin

```
/plugin marketplace add mikhailrojo/claude-telegram-notifications
/plugin install telegram-notifications@claude-telegram-notifications
```

### 3. Add your credentials to `~/.claude/settings.json`

```json
{
  "env": {
    "TG_BOT_TOKEN": "your-bot-token",
    "TG_CHAT_ID": "your-chat-id"
  }
}
```

Done. Restart Claude Code and notifications will start arriving.
