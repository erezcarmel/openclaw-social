# Orchestrator Onboarding

This file signals a first-run setup. Work through every step below, then delete this file.

**Config repo**: https://github.com/erezcarmel/openclaw-social  
**Raw content base**: https://raw.githubusercontent.com/erezcarmel/openclaw-social/main

---

## Steps

### 1. Read the fleet manifest

Fetch:
```
https://raw.githubusercontent.com/erezcarmel/openclaw-social/main/agents.yaml
```
Parse it to learn all agent IDs, models, roles, and Telegram bindings. This is the single source of truth for the fleet.

---

### 2. Read each agent's identity files

For **`researcher`**, **`writer`**, and **`editor`** — fetch each file below and write it verbatim to that agent's workspace.

| File | URL pattern |
|------|-------------|
| `SOUL.md` | `.../agents/{id}/SOUL.md` |
| `AGENTS.md` | `.../agents/{id}/AGENTS.md` |
| `IDENTITY.md` | `.../agents/{id}/IDENTITY.md` |

Full URLs (replace `{id}` with agent ID):
```
https://raw.githubusercontent.com/erezcarmel/openclaw-social/main/agents/{id}/SOUL.md
https://raw.githubusercontent.com/erezcarmel/openclaw-social/main/agents/{id}/AGENTS.md
https://raw.githubusercontent.com/erezcarmel/openclaw-social/main/agents/{id}/IDENTITY.md
```

Workspace paths (set by `setup.sh`):
```
~/.openclaw/workspace-researcher/
~/.openclaw/workspace-writer/
~/.openclaw/workspace-editor/
```

---

### 3. Read your own operating procedures

Fetch and write to your own workspace:
```
https://raw.githubusercontent.com/erezcarmel/openclaw-social/main/agents/orchestrator/AGENTS.md
https://raw.githubusercontent.com/erezcarmel/openclaw-social/main/agents/orchestrator/HEARTBEAT.md
https://raw.githubusercontent.com/erezcarmel/openclaw-social/main/workflows/article-pipeline.md
```

Save `article-pipeline.md` as `PIPELINE.md` in your workspace so you can reference it at any time.

---

### 4. Initialize MEMORY.md

Create `MEMORY.md` in your workspace with an empty Kanban board:

```markdown
# Memory

## Kanban Board

| Topic | Column | Agent | Revision# | Updated |
|-------|--------|-------|-----------|---------|

## Config
Repo: https://github.com/erezcarmel/openclaw-social
Last synced: {TODAY}
```

Replace `{TODAY}` with today's date.

---

### 5. Announce readiness in Telegram

Post this message to the group:
```
🦞 Orchestrator: ✅ Fleet online — configured from github.com/erezcarmel/openclaw-social.
Agents ready: @researcher (DeepSeek V3), @writer (Claude Haiku), @editor (Claude Sonnet).
Send me a topic to write about.
```

---

### 6. Delete this file

Remove `ONBOARD.md` from your workspace. Onboarding is complete. Normal operations begin.

---

## Re-syncing Later

To pull updated agent definitions from the repo at any time (without a full re-setup), a user can send:
```
@orchestrator sync from repo
```
You should then repeat steps 1–3 above and post a confirmation. Skip steps 4–6.
