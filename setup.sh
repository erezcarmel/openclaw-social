#!/usr/bin/env bash
# OpenCLAW Social — One-Command Setup
# Reads agents.yaml and provisions the full agent fleet.
# Re-running is safe: existing agents are updated, not duplicated.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_HOME="$HOME/.openclaw"
CONFIG_FILE="$OPENCLAW_HOME/openclaw.json"

echo ""
echo "========================================="
echo "  OpenCLAW Social — Agent Setup"
echo "========================================="
echo ""

# ── Preflight checks ───────────────────────────────────────────────────────
if ! command -v openclaw &>/dev/null; then
  echo "❌  openclaw CLI not found."
  echo "    Install it with: npm install -g openclaw"
  exit 1
fi

echo "✅  openclaw CLI found: $(openclaw --version 2>/dev/null || echo 'unknown version')"
echo ""

# ── Collect credentials ────────────────────────────────────────────────────
echo "Credentials are collected once and stored in ~/.openclaw/ only."
echo "Nothing is written back to this repository."
echo ""

prompt_secret() {
  local var_name="$1" prompt_text="$2"
  local value
  printf "%s: " "$prompt_text"
  read -rs value
  echo ""
  eval "$var_name=\"$value\""
}

prompt_secret OPENAI_API_KEY     "OpenAI API key (for Writer + Editor — get at platform.openai.com)"
prompt_secret DEEPSEEK_API_KEY   "DeepSeek API key (for Orchestrator + Researcher — get at platform.deepseek.com)"
prompt_secret TELEGRAM_BOT_TOKEN "Telegram bot token (from @BotFather)"
printf "Telegram group chat ID (e.g. -1001234567890): "
read -r TELEGRAM_GROUP_ID
echo ""

# ── Register API keys ──────────────────────────────────────────────────────
echo "Registering API keys..."
echo "$OPENAI_API_KEY"   | openclaw models auth paste-token --provider openai
echo "$DEEPSEEK_API_KEY" | openclaw models auth paste-token --provider deepseek

# ── Agent definitions (mirrors agents.yaml) ────────────────────────────────
# Format: id|display_name|emoji|model|workspace_suffix
# DeepSeek V3 for routing/research; GPT-4o-mini for writing/editing.
AGENTS=(
  "orchestrator|🦞 Orchestrator|🦞|deepseek/deepseek-chat|workspace-orchestrator"
  "researcher|🔍 Researcher|🔍|deepseek/deepseek-chat|workspace-researcher"
  "writer|✍️ Writer|✍️|openai/gpt-4o-mini|workspace-writer"
  "editor|📝 Editor|📝|openai/gpt-4o-mini|workspace-editor"
)

# ── Provision each agent ───────────────────────────────────────────────────
echo ""
echo "Registering agents..."

REPO_URL="https://github.com/erezcarmel/openclaw-social"
RAW_BASE="https://raw.githubusercontent.com/erezcarmel/openclaw-social/main"

for AGENT_ENTRY in "${AGENTS[@]}"; do
  IFS='|' read -r ID NAME EMOJI MODEL WORKSPACE_SUFFIX <<< "$AGENT_ENTRY"
  WORKSPACE="$OPENCLAW_HOME/$WORKSPACE_SUFFIX"

  echo "  → $NAME ($ID)..."

  openclaw agents add "$ID" \
    --model "$MODEL" \
    --workspace "$WORKSPACE"

  openclaw agents set-identity "$ID" \
    --name "$NAME" \
    --emoji "$EMOJI"

  mkdir -p "$WORKSPACE"
done

# ── Place ONBOARD.md in Orchestrator workspace ─────────────────────────────
# The Orchestrator reads this on first startup and fetches all agent
# definitions from the GitHub repo, seeding each agent's workspace itself.
ORCH_WORKSPACE="$OPENCLAW_HOME/workspace-orchestrator"
mkdir -p "$ORCH_WORKSPACE"
cp "$REPO_DIR/agents/orchestrator/ONBOARD.md" "$ORCH_WORKSPACE/ONBOARD.md"
cp "$REPO_DIR/agents/orchestrator/SOUL.md"    "$ORCH_WORKSPACE/SOUL.md"
echo "  Orchestrator bootstrap files written → $ORCH_WORKSPACE"

# ── Write openclaw.json ────────────────────────────────────────────────────
echo ""
echo "Writing openclaw.json..."
mkdir -p "$OPENCLAW_HOME"

# Backup existing config
if [ -f "$CONFIG_FILE" ]; then
  cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
  echo "  Backed up existing config → openclaw.json.bak"
fi

# Substitute placeholders and write live config (no secrets in this repo)
sed \
  -e "s|\${TELEGRAM_BOT_TOKEN}|$TELEGRAM_BOT_TOKEN|g" \
  -e "s|\${TELEGRAM_GROUP_ID}|$TELEGRAM_GROUP_ID|g" \
  "$REPO_DIR/openclaw.json.example" > "$CONFIG_FILE"

echo "  Config written → $CONFIG_FILE"

# ── Done ───────────────────────────────────────────────────────────────────
echo ""
echo "========================================="
echo "  ✅  Setup complete!"
echo "========================================="
echo ""
echo "Start OpenCLAW:"
echo "  openclaw"
echo ""
echo "Web UI (once running):"
echo "  http://127.0.0.1:18789/openclaw"
echo ""
echo "On first startup, the Orchestrator will automatically:"
echo "  1. Fetch agent definitions from github.com/erezcarmel/openclaw-social"
echo "  2. Seed each agent workspace (Researcher, Writer, Editor)"
echo "  3. Announce readiness in your Telegram group"
echo ""
echo "Once the Orchestrator posts '✅ Fleet online' in Telegram, send:"
echo '  Write an article about: [your topic]'
echo ""
echo "To re-sync agent definitions from the repo at any time, send:"
echo "  @orchestrator sync from repo"
echo ""
echo "To add LinkedIn, Twitter, or other agents later:"
echo "  See docs/adding-agents.md"
echo ""
