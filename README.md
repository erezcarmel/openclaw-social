# OpenCLAW Social — Agent Configuration Repository

This repository contains the complete agent definitions and configuration for **OpenCLAW Social** — an autonomous multi-agent system that manages social media accounts (LinkedIn, Twitter) and writes articles for Medium.

OpenCLAW reads this repository to configure itself. Clone it, run `setup.sh`, and your agent team is live.

## Architecture

```
🦞 Orchestrator (Kanban manager)
├── 🔍 Researcher   — trend analysis & data gathering
├── ✍️  Writer       — article drafting (Medium, 4-min read)
└── 📝 Editor       — quality review & approval
```

All agents communicate visibly in a shared Telegram group, referencing each other by agent ID. The Orchestrator manages a Kanban board tracking every article from idea to approval.

## Getting Started

### Prerequisites
- Node.js 24+ (or 22.19+ LTS)
- OpenCLAW CLI: `npm install -g openclaw`
- OpenAI API key
- DeepSeek API key
- Telegram bot token (from @BotFather)

### One-Command Setup

```bash
git clone https://github.com/erezcarmel/openclaw-social.git
cd openclaw-social
chmod +x setup.sh
./setup.sh
```

The script will prompt for your API keys, Telegram bot token, and group chat ID — then configure and start the agent fleet. No secrets are stored in this repo.

## File Structure

```
agents/
├── orchestrator/   Kanban workflow manager (entry point)
├── researcher/     Trend analysis and data gathering
├── writer/         Article drafting (800–1000 words)
└── editor/         Quality review and approval
workflows/
└── article-pipeline.md   Full pipeline definition
docs/
├── adding-agents.md      How to add LinkedIn, Twitter, etc. later
└── team-channels.md      Telegram group setup guide
agents.yaml              Agent fleet manifest (IDs, models, roles)
openclaw.json.example    Gateway config template (no secrets)
.env.example             Environment variable reference
setup.sh                 One-command provisioning script
```

## Article Writing Flow

```
User sends topic in Telegram group
         │
         ▼ Backlog → Research
🔍 Researcher gathers trend data (≤500 words)
         │
         ▼ Research → Writing
✍️  Writer drafts 800–1000 word article
         │
         ▼ Writing → Editing
📝 Editor reviews → APPROVE or REQUEST_REVISION
         │              └──────────────────────┐
         ▼ Editing → Done        (max 3 cycles)│
🦞 Orchestrator notifies user with final article
```

Every step is announced visibly in the Telegram group by the acting agent.

## Token Cost Efficiency

| Agent | Model | Reason |
|-------|-------|--------|
| 🦞 Orchestrator | DeepSeek V3 | Routing logic only — cheapest option for structured tasks |
| 🔍 Researcher | DeepSeek V3 | Structured bullet summaries — DeepSeek excels here |
| ✍️ Writer | GPT-4o-mini | Cost-efficient prose quality on OpenAI |
| 📝 Editor | GPT-4o-mini | Strong reasoning at a fraction of GPT-4o cost |

- Research brief hard-capped at 500 words → limits Writer's token input
- Sub-agents spawned with `context: isolated` → no conversation history bleed
- SOUL.md files kept concise — they load on every agent turn

## Adding More Agents

See [docs/adding-agents.md](docs/adding-agents.md) for how to add LinkedIn, Twitter, and other social agents. The guide includes templates and step-by-step instructions for connecting them as a team in Telegram.

## Security

No API keys or tokens are stored in this repository. All credentials are collected interactively by `setup.sh` and written to `~/.openclaw/` only. Never commit `.env` to version control.
