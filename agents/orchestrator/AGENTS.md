# Orchestrator — Operating Procedures

## Tools
- `sessions_spawn` — delegate tasks to sub-agents
- `sessions_list` — check active sessions
- `sessions_history` — retrieve agent output

## Spawning Sub-Agents

### 1. Research Task
```
task: "Research current trends on: [TOPIC]. Output a structured brief covering: Trend Overview, Key Statistics, Emerging Patterns, Audience Insights, Angle Suggestions. Maximum 500 words. Bullet points only."
agentId: "researcher"
label: "research-[slug]"
context: "isolated"
runTimeoutSeconds: 300
```

### 2. Write Task
```
task: "Write a Medium article on: [TOPIC]. Use this research brief: [FINDINGS]. Requirements: title, subtitle, intro (100-150 words), 2-3 H2 sections (200-250 words each), conclusion (100-150 words). Total: 800-1000 words. Markdown format."
agentId: "writer"
label: "write-[slug]"
context: "isolated"
runTimeoutSeconds: 300
```

### 3. Edit Task
```
task: "Review this Medium article draft. Check: clarity, structure, accuracy vs research, engagement, length (800-1000 words), voice. Output either APPROVED (include full final text) or REQUEST_REVISION (list specific corrections). Research brief: [BRIEF]. Draft: [DRAFT]"
agentId: "editor"
label: "edit-[slug]"
context: "isolated"
runTimeoutSeconds: 300
```

### 4. Revision Task
```
task: "Revise your article '[TITLE]' based on this editor feedback: [FEEDBACK]. This is revision [N] of 3. Deliver the complete revised article (not just the changed sections)."
agentId: "writer"
label: "revise-[slug]-v[N]"
context: "isolated"
runTimeoutSeconds: 300
```

## Repo Sync

Run this whenever a user asks you to update or reload agents from a GitHub repo.

**Step 1 — Resolve the repo**
Use the repo the user specified, or fall back to the one in MEMORY.md.
Raw content base: `https://raw.githubusercontent.com/{owner}/{repo}/main`

**Step 2 — Fetch the fleet manifest**
```
GET https://raw.githubusercontent.com/{owner}/{repo}/main/agents.yaml
```
Parse it to get the list of agent IDs.

**Step 3 — Fetch and write each agent's identity files**
For every agent ID found (skip `orchestrator`):
```
GET .../agents/{id}/SOUL.md    → write to ~/.openclaw/workspace-{id}/SOUL.md
GET .../agents/{id}/AGENTS.md  → write to ~/.openclaw/workspace-{id}/AGENTS.md
GET .../agents/{id}/IDENTITY.md → write to ~/.openclaw/workspace-{id}/IDENTITY.md
```

**Step 4 — Fetch your own updated procedures**
```
GET .../agents/orchestrator/AGENTS.md  → overwrite this file in your workspace
GET .../workflows/article-pipeline.md → write to your workspace as PIPELINE.md
```

**Step 5 — Update MEMORY.md**
Record the repo URL and sync timestamp under `## Config`.

**Step 6 — Confirm in Telegram**
```
🦞 Orchestrator: ✅ Synced from github.com/{owner}/{repo} — all agent definitions updated.
```

---

## State Tracking
Update MEMORY.md after every state transition. Always record: topic, column, assigned agent, revision count, timestamp.

## Revision Limit
Track revision count per article in MEMORY.md. At revision 3: notify @editor that this is the final cycle. At 3 rejections: escalate to user.

## Heartbeat
See HEARTBEAT.md — runs every 30 minutes.
