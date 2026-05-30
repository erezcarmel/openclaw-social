# Team Channels — Telegram Setup

## Overview

All OpenCLAW Social agents share one Telegram group. Each agent has its own identity and responds when mentioned. The Orchestrator listens to all messages and is the primary entry point.

---

## Step 1 — Create the Telegram Bot

1. Open Telegram and message **@BotFather**
2. Send `/newbot`
3. Choose a name and username for your bot
4. Copy the **API token** — enter it when `setup.sh` prompts you
5. Keep the token secret — `.env` only, never the repo

---

## Step 2 — Create the Telegram Group

1. Create a new Telegram group (e.g., "OpenCLAW Social Team")
2. Add your bot and promote it to **Admin**
3. Get the group **chat ID** (negative integer):
   - Send any message in the group
   - Visit: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
   - Find `"chat": { "id": -1001234567890 }` and copy the number
4. Enter this as `TELEGRAM_GROUP_ID` when `setup.sh` prompts you

---

## What Agent Communication Looks Like

```
You: Write an article about: AI in healthcare 2026

🦞 Orchestrator: "AI in healthcare 2026" → Research
🦞 Orchestrator: @researcher please research this topic.

🔍 Researcher: Brief on "AI in healthcare 2026" delivered to @writer.
## Research Brief: AI in Healthcare 2026
- AI diagnostic accuracy now exceeds radiologists in 3 specialties...

✍️ Writer: Draft complete (~920 words). Sending to @editor.
# How AI is Quietly Saving Lives in 2026
*The diagnostic revolution no one outside hospitals is talking about*

📝 Editor: ✅ APPROVED — "How AI is Quietly Saving Lives in 2026".

🦞 Orchestrator: ✅ Article ready!
[Full final article...]
Kanban: Done ✅
```

---

## Agent Mention Rules

| Agent | Telegram | Condition |
|-------|----------|-----------|
| 🦞 Orchestrator | Listens to everything | Always active |
| 🔍 Researcher | Responds to `@researcher` | `requireMention: true` |
| ✍️ Writer | Responds to `@writer` | `requireMention: true` |
| 📝 Editor | Responds to `@editor` | `requireMention: true` |

---

## Starting an Article

```
Write an article about: [topic]
New article: [topic]
Research and write a Medium post on: [topic]
```

---

## Adding a New Agent

1. Add to `agents.yaml` with the same `channel: telegram` binding
2. Re-run `./setup.sh`
3. Agent joins the group automatically and responds when `@[agentid]` is mentioned

---

## Troubleshooting

**Bot not responding**: Ensure bot is Admin, check `TELEGRAM_BOT_TOKEN`, confirm `openclaw` is running.

**Wrong agent responding**: Verify `requireMention: true` for all specialist agents.

**Group ID is wrong**: IDs are negative integers. Use `getUpdates` to confirm. Re-run `./setup.sh`.

**Agent not reading history**: Sub-agents use `context: isolated` by design — cost efficiency. Orchestrator maintains state in MEMORY.md.
