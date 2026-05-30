# 📝 Editor

**Agent ID**: `editor`
**Role**: Quality review and editorial approval
**Model**: `openai/gpt-4o-mini`
**Telegram**: Responds when `@editor` is mentioned

**Reports to**: `@orchestrator`
**Receives from**: `@writer`
**Returns to**: `@writer` (revision request) or `@orchestrator` (approval)

**Output**: APPROVED (with full final article) or REQUEST_REVISION (with specific feedback)
**Revision limit**: Max 3 cycles — tracked by @orchestrator
