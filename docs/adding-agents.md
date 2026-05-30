# Adding New Agents

How to extend the OpenCLAW Social fleet with new specialist agents — for example, a LinkedIn post writer, Twitter/X thread creator, or any other social or content agent.

## What Every New Agent Needs

1. An entry in `agents.yaml`
2. A directory `agents/<id>/` with identity files
3. A binding entry in `openclaw.json.example`
4. A spawn template in the Orchestrator's `AGENTS.md`
5. Re-run `setup.sh`

---

## Step 1 — Add to agents.yaml

```yaml
- id: "linkedin"
  name: "💼 LinkedIn"
  emoji: "💼"
  role: "LinkedIn post creation from approved articles"
  model: "openai/gpt-4o-mini"
  protected: false
  workspace: ".agents/linkedin"
```

> **Model tip**: Use `deepseek/deepseek-chat` for routing/data agents, `openai/gpt-4o-mini` for writing and judgment agents.

---

## Step 2 — Create Agent Identity Files

```
agents/linkedin/
├── SOUL.md      Required — personality, role, communication rules
├── AGENTS.md    Required — output format, constraints, procedures
└── IDENTITY.md  Required — public card (ID, model, reports-to chain)
```

### SOUL.md Template

```markdown
# [Emoji] [Agent Name]

## Identity
You are the **[Name]** agent for OpenCLAW Social. [One sentence describing the role.]

## Task
[What the agent does when spawned. Input received and output delivered.]

## Output Format
[Exact format specification. Include hard length/character limits.]

## Communication
- Prefix all messages: `[Emoji] [Name]:`
- On completion: `[Emoji] [Name]: [Task] complete. [Next step].`
- Report to @orchestrator

## Platform Rules
[Platform-specific constraints — character limits, hashtag conventions, tone.]

## Tone
[Voice for the platform — professional for LinkedIn, punchy for Twitter]
```

### AGENTS.md Template

```markdown
# [Name] — Operating Procedures

## Output Format
[Exact markdown structure with example]

## Constraints
- [Hard limit 1]
- [Hard limit 2]
- Always report completion to @orchestrator
```

### IDENTITY.md Template

```markdown
# [Emoji] [Agent Name]

**Agent ID**: `[id]`
**Role**: [Brief role description]
**Model**: `[model-id]`
**Telegram**: Responds when `@[id]` is mentioned

**Reports to**: `@orchestrator`
**Receives from**: [source]
**Delivers to**: [destination]

**Output**: [One sentence description]
```

---

## Step 3 — Add Binding to openclaw.json.example

```json
{
  "agentId": "linkedin",
  "match": {
    "channel": "telegram",
    "groupId": "${TELEGRAM_GROUP_ID}",
    "requireMention": true
  }
}
```

Add `"linkedin"` to `subagents.allowAgents` list too.

---

## Step 4 — Add Spawn Template to Orchestrator's AGENTS.md

```
### LinkedIn Post Task
task: "Write a LinkedIn post based on this approved article. Article: [ARTICLE_TEXT]. Requirements: professional tone, 150-300 words, 3-5 relevant hashtags, end with a question to drive engagement."
agentId: "linkedin"
label: "linkedin-[slug]"
context: "isolated"
runTimeoutSeconds: 180
```

---

## Step 5 — Re-run Setup

```bash
./setup.sh
```

---

## Connecting Agents as a Team in Telegram

- All bindings use the same `groupId` (set during setup)
- New agents respond when `@[agentid]` is mentioned
- Agents address each other by ID: `@researcher`, `@writer`, `@editor`, `@linkedin`
- `requireMention: true` keeps the group clean
- The Orchestrator coordinates via `sessions_spawn`

See [team-channels.md](team-channels.md) for Telegram group setup details.

---

## Example: Twitter/X Agent

```yaml
- id: "twitter"
  name: "🐦 Twitter"
  emoji: "🐦"
  role: "Twitter/X thread creation from approved articles"
  model: "openai/gpt-4o-mini"
  protected: false
  workspace: ".agents/twitter"
```

Spawn template:
```
task: "Write a Twitter/X thread based on this article. Article: [ARTICLE_TEXT]. Format: 5-8 tweets, each ≤280 characters. Tweet 1 = hook. Final tweet = CTA. Numbered 1/N format."
agentId: "twitter"
label: "twitter-[slug]"
context: "isolated"
runTimeoutSeconds: 180
```
