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

# ── Preflight checks ──────────────────────────────────────────────────────
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

prompt_secret ANTHROPIC_API_KEY  "Anthropic API key (for Writer + Editor)"
prompt_secret DEEPSEEK_API_KEY   "DeepSeek API key (for Orchestrator + Researcher — get at platform.deepseek.com)"
prompt_secret TELEGRAM_BOT_TOKEN "Telegram bot token (from @BotFather)"
printf "Telegram group chat ID (e.g. -1001234567890): "
read -r TELEGRAM_GROUP_ID
echo ""

# ── Register API keys ──────────────────────────────────────────────────────
echo "Registering API keys..."
echo "$ANTHROPIC_API_KEY" | openclaw models auth paste-token --provider anthropic
echo "$DEEPSEEK_API_KEY"  | openclaw models auth paste-token --provider deepseek

# ── Agent definitions (mirrors agents.yaml) ────────────────────────────────
# Format: id|display_name|emoji|model|workspace_suffix
# DeepSeek V3 for routing/research (~3-4x cheaper); Claude for writing/editing.
AGENTS=(
  "orchestrator|🦞 Orchestrator|🦞|deepseek/deepseek-chat|workspace-orchestrator"
  "researcher|🔍 Researcher|🔍|deepseek/deepseek-chat|workspace-researcher"
  "writer|✍️ Writer|✍️|anthropic/claude-haiku-4-5-20251001|workspace-writer"
  "editor|📝 Editor|📝|anthropic/claude-sonnet-4-6|workspace-editor"
)

# ── Provision each agent ───────────────────────────────────────────────────
echo ""
echo "Registering agents..."

for AGENT_ENTRY in "${AGENTS[@]}"; do
  IFS='|' read -r ID NAME EMOJI MODEL WORKSPACE_SUFFIX <<< "$AGENT_ENTRY"
  WORKSPACE="$OPENCLAW_HOME/$WORKSPACE_SUFFIX"
  SRC="$REPO_DIR/agents/$ID"

  echo "  → $NAME ($ID)..."

  openclaw agents add "$ID" \
    --model "$MODEL" \
    --workspace "$WORKSPACE"

  openclaw agents set-identity "$ID" \
    --name "$NAME" \
    --emoji "$EMOJI"

  mkdir -p "$WORKSPACE"
  if [ -d "$SRC" ]; then
    for FILE in SOUL.md AGENTS.md IDENTITY.md HEARTBEAT.md; do
      if [ -f "$SRC/$FILE" ]; then
        cp "$SRC/$FILE" "$WORKSPACE/_source_${FILE}"
        echo "     Staged $FILE"
      fi
    done

    cat > "$WORKSPACE/BOOTSTRAP.md" << 'BOOTSTRAP'
# First-Run Bootstrap (delete this file after completing)

1. Read `_source_SOUL.md` and merge its content into your `SOUL.md`
2. Read `_source_AGENTS.md` and merge its content into your `AGENTS.md`
3. If `_source_IDENTITY.md` exists, copy it to `IDENTITY.md`
4. If `_source_HEARTBEAT.md` exists, copy it to `HEARTBEAT.md`
5. Delete all `_source_*.md` files and this `BOOTSTRAP.md`
6. Proceed with your normal role as defined in SOUL.md
BOOTSTRAP
  fi
done

# ── Write openclaw.json ────────────────────────────────────────────────────
echo ""
echo "Writing openclaw.json..."
mkdir -p "$OPENCLAW_HOME"

if [ -f "$CONFIG_FILE" ]; then
  cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
  echo "  Backed up existing config → openclaw.json.bak"
fi

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
echo "To kick off an article, send this in your Telegram group:"
echo '  Write an article about: [your topic]'
echo ""
echo "To add LinkedIn, Twitter, or other agents later:"
echo "  See docs/adding-agents.md"
echo ""
