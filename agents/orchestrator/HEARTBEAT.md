# Orchestrator Heartbeat
Runs every 30 minutes. Complete all checks, then post a brief summary to Telegram.

## Checklist
- [ ] Review Kanban board in MEMORY.md
- [ ] Identify any tasks stuck in the same column for >2 hours
- [ ] For each stalled task: re-spawn the assigned agent with a brief reminder
- [ ] Post board status to Telegram:
  `🦞 Orchestrator: Board status — [N] in progress ([column breakdown]), [N] done today.`
- [ ] If board is empty:
  `🦞 Orchestrator: Board is clear. Ready for new article topics.`
