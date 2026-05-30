# Article Writing Pipeline

## Purpose
End-to-end flow for producing a Medium article draft — from topic request to user notification.

## Flow Diagram

```
User message in Telegram
         │
         ▼  topic received
     [Backlog]
         │
         ▼  spawn @researcher
     [Research]
         │  brief delivered (≤500 words)
         ▼  spawn @writer
     [Writing] ◄──────────────────────────┐
         │  draft delivered (800-1000 words)│
         ▼  spawn @editor                  │
     [Editing]                             │
         │                                 │
    APPROVE ──────────────────┐   REQUEST_REVISION
         │                    │            │
         ▼                    │     @writer revises
      [Done]                  │     (max 3 cycles)
         │                    │            │
         ▼                    │   cycle 3 + reject
   Notify user                │   → escalate to user
                              │
              Full article posted to Telegram
```

## Step Definitions

### Step 1 — Topic Assignment
**Trigger**: User message containing a topic request
**Actor**: Orchestrator
**Action**: Create Kanban card, move to Research, spawn @researcher
**Telegram**: `🦞 Orchestrator: Starting "[topic]" → Research`

---

### Step 2 — Research Phase
**Actor**: @researcher
**Input**: Topic string
**Output**: Research brief (≤500 words, structured markdown)
**Completes when**: Brief posted to Telegram chat
**Telegram**: `🔍 Researcher: Brief on "[topic]" delivered to @writer.`
**Kanban**: Research → Writing

---

### Step 3 — Writing Phase
**Actor**: @writer
**Input**: Research brief from @researcher
**Output**: Article draft (800–1000 words, markdown with H2 headers)
**Completes when**: Draft posted to Telegram and @editor notified
**Telegram**: `✍️ Writer: Draft on "[topic]" complete (~[N] words). Sending to @editor.`
**Kanban**: Writing → Editing

---

### Step 4 — Editing Phase
**Actor**: @editor
**Input**: Article draft + research brief (for accuracy checking)

**Decision A — APPROVE**:
- Telegram: `📝 Editor: ✅ APPROVED — "[title]". Sending final to @orchestrator.`
- Kanban: Editing → Done

**Decision B — REQUEST_REVISION**:
- Telegram: `📝 Editor: 🔄 REVISION REQUESTED — "[title]". Feedback sent to @writer.`
- Kanban: Editing → Writing (revision cycle N)
- Maximum 3 revision cycles per article

---

### Step 5 — Completion
**Actor**: Orchestrator
**Telegram**:
```
🦞 Orchestrator: ✅ Article ready!

[Full article text]

Kanban: Done ✅
```

---

## Article Specifications

| Property | Value |
|----------|-------|
| Platform | Medium |
| Length | 800–1000 words |
| Reading time | ~4 minutes |
| Format | Markdown with H2 headers |
| Tone | Conversational, authoritative |
| Audience | Tech-aware professionals |

---

## Token Efficiency Design

| Agent | Model | Why |
|-------|-------|-----|
| Orchestrator | DeepSeek V3 | Routing and Kanban state — cheapest option for structured tasks |
| Researcher | DeepSeek V3 | Structured bullet-point summaries — DeepSeek excels here |
| Writer | GPT-4o-mini | Cost-efficient prose quality on OpenAI |
| Editor | GPT-4o-mini | Strong reasoning at a fraction of GPT-4o cost |

- Research brief capped at 500 words → limits Writer's context size
- All sub-agents use `context: isolated` → no conversation history bleed
- SOUL.md files are kept concise — they load on every agent turn
- Revision limit of 3 prevents infinite loops
