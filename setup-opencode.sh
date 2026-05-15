#!/bin/bash
#
# OpenCode Setup Script (macOS)
#
# Installs OpenCode AI coding agent + common dev tools on a fresh Mac.
# Run once:  bash setup-opencode.sh
# After that: type 'oc' to launch OpenCode.
#
# Idempotent — safe to re-run at any time.
#
# What gets installed:
#   - Homebrew (macOS package manager)
#   - Git, jq, Node.js (dev essentials)
#   - Docker Desktop (local containers)
#   - OpenCode CLI (AI coding agent)
#   - Superpowers skills plugin (brainstorming, TDD, debugging, etc.)
#
# What gets configured:
#   - ~/.config/opencode/opencode.jsonc (MCP servers, plugins, permissions)
#   - ~/.zshrc (PATH, API key env var, 'oc' launcher function)
#

set -u

# --- Colors ---
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
YELLOW=$'\e[93m'
NC=$'\e[0m'

ZSHRC="$HOME/.zshrc"
CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.jsonc"

# --- Helper functions ---
green_echo() { echo "${GREEN}$1${NC}"; }
red_echo()   { echo "${RED}$1${NC}"; }
yellow_echo(){ echo "${YELLOW}$1${NC}"; }

# -------------------------------------------
# Safety checks
# -------------------------------------------
if [ "$(id -u)" -eq 0 ]; then
  echo ""
  red_echo "  [FAIL] Do not run this script as root or with sudo."
  echo "         Just run: bash setup-opencode.sh"
  echo ""
  exit 1
fi

if [[ "$(uname)" != "Darwin" ]]; then
  red_echo "  [FAIL] This script is designed for macOS."
  echo "         For Linux, use: curl -fsSL https://opencode.ai/install | bash"
  exit 1
fi

echo ""
echo "========================================"
green_echo "  OpenCode Setup — Personal Edition"
echo "========================================"
echo ""

touch "$ZSHRC"

# -------------------------------------------
# Step 1: Install Homebrew (if needed)
# -------------------------------------------
echo "[1/8] Checking Homebrew..."

if command -v brew &>/dev/null; then
  green_echo "  [OK] Homebrew already installed."
else
  if ! xcode-select -p &>/dev/null; then
    yellow_echo "  Xcode Command Line Tools are required."
    echo "  A macOS dialog may appear — click 'Install' and wait."
    echo "  This can take 10-20 minutes on a fresh Mac."
    echo ""
  fi

  yellow_echo "  Installing Homebrew..."
  echo "  (You may be prompted for your Mac password)"
  echo ""
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    echo ""
    red_echo "  [FAIL] Homebrew installation failed."
    echo "  Check your internet connection and try again."
    exit 1
  fi
fi

# Identify Brew path based on architecture
if [ -f "/opt/homebrew/bin/brew" ]; then
  BREW_LINE='eval "$(/opt/homebrew/bin/brew shellenv)"'
  BREW_PATTERN='/opt/homebrew/bin/brew shellenv'
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
  BREW_LINE='eval "$(/usr/local/bin/brew shellenv)"'
  BREW_PATTERN='/usr/local/bin/brew shellenv'
  eval "$(/usr/local/bin/brew shellenv)"
else
  BREW_LINE=""
  BREW_PATTERN=""
fi

# Persist Homebrew to .zshrc
if [ -n "$BREW_LINE" ]; then
  if ! grep -q "$BREW_PATTERN" "$ZSHRC" 2>/dev/null; then
    echo "$BREW_LINE" >> "$ZSHRC"
    green_echo "  [OK] Homebrew PATH added to .zshrc."
  fi
fi

# -------------------------------------------
# Step 2: Install dev tools (git, jq, node)
# -------------------------------------------
echo ""
echo "[2/8] Checking dev tools..."

install_brew_pkg() {
  local pkg="$1"
  if command -v "$pkg" &>/dev/null; then
    green_echo "  [OK] $pkg already installed."
  else
    yellow_echo "  Installing $pkg..."
    brew install "$pkg" >/dev/null 2>&1
    green_echo "  [OK] $pkg installed."
  fi
}

install_brew_pkg git
install_brew_pkg jq

# Node.js — check for node, install via brew if missing
if command -v node &>/dev/null; then
  green_echo "  [OK] Node.js already installed ($(node --version))."
else
  yellow_echo "  Installing Node.js..."
  brew install node >/dev/null 2>&1
  green_echo "  [OK] Node.js installed."
fi

# -------------------------------------------
# Step 3: Install Docker Desktop (if needed)
# -------------------------------------------
echo ""
echo "[3/8] Checking Docker..."

if command -v docker &>/dev/null || [ -d "/Applications/Docker.app" ]; then
  green_echo "  [OK] Docker Desktop already installed."
else
  yellow_echo "  Installing Docker Desktop..."
  brew install --cask docker >/dev/null 2>&1
  if [ -d "/Applications/Docker.app" ]; then
    green_echo "  [OK] Docker Desktop installed."
    yellow_echo "  NOTE: Open Docker Desktop from Applications to complete first-time setup."
  else
    yellow_echo "  [WARN] Docker Desktop install may need manual setup."
    echo "  Download from: https://www.docker.com/products/docker-desktop/"
  fi
fi

# -------------------------------------------
# Step 4: Install OpenCode (if needed)
# -------------------------------------------
echo ""
echo "[4/8] Checking OpenCode..."

if command -v opencode &>/dev/null; then
  green_echo "  [OK] OpenCode already installed ($(opencode --version 2>/dev/null || echo 'version unknown'))."
else
  yellow_echo "  Installing OpenCode via Homebrew..."
  if ! brew install anomalyco/tap/opencode >/dev/null 2>&1; then
    echo ""
    red_echo "  [FAIL] Failed to install OpenCode via brew."
    echo "  Trying fallback: curl installer..."
    curl -fsSL https://opencode.ai/install | bash
  fi

  if command -v opencode &>/dev/null; then
    green_echo "  [OK] OpenCode installed."
  else
    red_echo "  [FAIL] OpenCode installation failed."
    echo "  Try manually: brew install anomalyco/tap/opencode"
    echo "  Or: curl -fsSL https://opencode.ai/install | bash"
    exit 1
  fi
fi

# -------------------------------------------
# Step 5: Write OpenCode config
# -------------------------------------------
echo ""
echo "[5/8] Configuring OpenCode..."

mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
  green_echo "  [OK] Config already exists at $CONFIG_FILE, skipping."
  echo "  (Delete it and re-run to regenerate.)"
else
  cat > "$CONFIG_FILE" << 'OCEOF'
{
  "$schema": "https://opencode.ai/config.json",
  // Disable session sharing by default
  "share": "disabled",

  // Use a cheap model for lightweight tasks (title generation, etc.)
  // This avoids burning expensive tokens on housekeeping.
  // Change this to match your provider — examples:
  //   "anthropic/claude-haiku-4-5"  (Anthropic)
  //   "openai/gpt-4o-mini"          (OpenAI)
  "small_model": "anthropic/claude-haiku-4-5",

  // Compaction — controls how OpenCode manages long conversations
  "compaction": {
    // Automatically compact when context window fills up (saves tokens)
    "auto": true,
    // Remove old tool outputs to reclaim space
    "prune": true,
    // Reserve 10k tokens buffer for the compaction process itself
    "reserved": 10000
  },

  // Plugins — extends OpenCode with skills and integrations
  "plugin": [
    // Superpowers: a complete dev methodology with brainstorming, TDD,
    // systematic debugging, code review, parallel agents, and more.
    // https://github.com/obra/superpowers
    "superpowers@git+https://github.com/obra/superpowers.git"
  ],

  // MCP servers — external tool integrations
  "mcp": {
    // Context7: search library/framework docs (free, no auth)
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    },
    // Grep by Vercel: search GitHub code examples (free, no auth)
    "gh_grep": {
      "type": "remote",
      "url": "https://mcp.grep.app",
      "enabled": true
    },
    // Cloudflare Docs: search Cloudflare product documentation (free, no auth)
    "cloudflare-docs": {
      "type": "remote",
      "url": "https://docs.mcp.cloudflare.com/mcp",
      "enabled": true
    }
  },

  // Permission defaults — safe out of the box
  "permission": {
    "edit": "allow",
    "webfetch": "allow",
    "bash": {
      "*": "allow",
      "rm *": "ask",
      "rm -rf ~*": "deny",
      "rm -rf /*": "deny",
      "sudo *": "ask",
      "git *": "ask",
      "git status*": "allow",
      "git log*": "allow",
      "git diff*": "allow",
      "git show*": "allow",
      "git rev-parse*": "allow",
      "git branch": "allow",
      "git branch -*": "allow",
      "git branch --*": "allow",
      "git fetch*": "allow",
      "git worktree list*": "allow",
      "git stash list*": "allow",
      "git stash show*": "allow",
      "git remote -v*": "allow",
      "git remote show*": "allow",
      "git remote get-url*": "allow",
      "git tag": "allow",
      "git tag -l*": "allow",
      "git tag --list*": "allow",
      "git submodule status": "allow",
      "git commit *": "ask",
      "git push*": "ask",
      "git pull*": "ask",
      "git merge*": "ask",
      "git rebase*": "ask",
      "git cherry-pick*": "ask",
      "git revert*": "ask",
      "git tag *": "ask",
      "git *--force*": "deny",
      "git reset --hard*": "deny",
      "git clean -f*": "deny",
      "git branch -D *": "ask",
      "git branch -d *": "ask",
      "git worktree remove*": "ask",
      "git checkout -- *": "ask",
      "git restore *": "ask",
      "git stash drop*": "ask",
      "git stash clear*": "ask"
    }
  }
}
OCEOF
  green_echo "  [OK] Config written to $CONFIG_FILE"
fi

# -------------------------------------------
# Step 6: Install skills
# -------------------------------------------
echo ""
echo "[6/8] Setting up skills..."

# --- Superpowers plugin (via opencode.jsonc) ---
if grep -q "superpowers" "$CONFIG_FILE" 2>/dev/null; then
  green_echo "  [OK] Superpowers plugin configured (auto-installs on first launch)."
  echo "  Includes: brainstorming, TDD, systematic-debugging, writing-plans,"
  echo "  executing-plans, code-review, parallel-agents, verification."
else
  yellow_echo "  [WARN] Superpowers not found in config."
  echo "  You can add it manually to opencode.jsonc:"
  echo '  "plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]'
fi

# --- Custom skills (bundled with this repo) ---
SKILLS_SRC_DIR="$(cd "$(dirname "$0")" && pwd)/skills"
SKILLS_DST_DIR="$CONFIG_DIR/skills"

if [ -d "$SKILLS_SRC_DIR" ]; then
  mkdir -p "$SKILLS_DST_DIR"
  for skill_dir in "$SKILLS_SRC_DIR"/*/; do
    skill_name="$(basename "$skill_dir")"
    dst="$SKILLS_DST_DIR/$skill_name"
    if [ -f "$skill_dir/SKILL.md" ]; then
      mkdir -p "$dst"
      cp "$skill_dir/SKILL.md" "$dst/SKILL.md"
      green_echo "  [OK] Installed skill: $skill_name"
    fi
  done
else
  yellow_echo "  [INFO] No bundled skills directory found (running from curl?)."
  echo "  To install custom skills, clone the repo and re-run the script."
fi

# -------------------------------------------
# Step 7: API key setup
# -------------------------------------------
echo ""
echo "[7/8] Setting up LLM provider..."

API_KEY_SET=false

# Check if any known API key env var is already in .zshrc
if grep -q 'ANTHROPIC_API_KEY\|OPENAI_API_KEY\|OPENROUTER_API_KEY' "$ZSHRC" 2>/dev/null; then
  green_echo "  [OK] API key already configured in .zshrc."
  API_KEY_SET=true
fi

if [ "$API_KEY_SET" = false ]; then
  echo ""
  echo "  OpenCode needs an API key from an LLM provider."
  echo "  Recommended: Anthropic (Claude) — https://console.anthropic.com/"
  echo "  Alternatives: OpenAI, OpenRouter, or use /connect in OpenCode later."
  echo ""
  echo "  Which provider?"
  echo "    1) Anthropic (Claude) — recommended"
  echo "    2) OpenAI (GPT)"
  echo "    3) OpenRouter (multi-provider)"
  echo "    s) Skip — I'll set it up later"
  echo ""
  read -p "  Choose [1/2/3/s]: " -n 1 -r PROVIDER_CHOICE
  echo ""

  case "$PROVIDER_CHOICE" in
    1)
      read -p "  Enter your Anthropic API key: " -r API_KEY
      if [ -n "$API_KEY" ]; then
        echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> "$ZSHRC"
        export ANTHROPIC_API_KEY="$API_KEY"
        green_echo "  [OK] ANTHROPIC_API_KEY saved to .zshrc."
      fi
      ;;
    2)
      read -p "  Enter your OpenAI API key: " -r API_KEY
      if [ -n "$API_KEY" ]; then
        echo "export OPENAI_API_KEY=\"$API_KEY\"" >> "$ZSHRC"
        export OPENAI_API_KEY="$API_KEY"
        green_echo "  [OK] OPENAI_API_KEY saved to .zshrc."
      fi
      ;;
    3)
      read -p "  Enter your OpenRouter API key: " -r API_KEY
      if [ -n "$API_KEY" ]; then
        echo "export OPENROUTER_API_KEY=\"$API_KEY\"" >> "$ZSHRC"
        export OPENROUTER_API_KEY="$API_KEY"
        green_echo "  [OK] OPENROUTER_API_KEY saved to .zshrc."
      fi
      ;;
    *)
      yellow_echo "  Skipped. You can configure a provider later with /connect in OpenCode."
      ;;
  esac
fi

# -------------------------------------------
# Step 8: Add 'oc' launcher to .zshrc
# -------------------------------------------
echo ""
echo "[8/8] Setting up 'oc' launcher..."

# Remove old version if present, then add current
if grep -q '# --- OpenCode launcher' "$ZSHRC" 2>/dev/null; then
  yellow_echo "  Updating 'oc' command in .zshrc..."
  # Use sed to remove the old block
  sed -i '' '/# --- OpenCode launcher/,/^}/d' "$ZSHRC"
fi

cat >> "$ZSHRC" << 'ZSHEOF'
# --- OpenCode launcher (added by setup-opencode.sh) ---
oc() {
  opencode "$@"
}
ZSHEOF

green_echo "  [OK] 'oc' command ready."

# -------------------------------------------
# Done
# -------------------------------------------
echo ""
echo "========================================"
green_echo "  Setup complete!"
echo "========================================"
echo ""
echo "  What was installed:"
echo "    - Homebrew (package manager)"
echo "    - Git, jq, Node.js (dev tools)"
echo "    - Docker Desktop (containers)"
echo "    - OpenCode (AI coding agent)"
echo ""
echo "  What was configured:"
echo "    - Superpowers plugin (brainstorming, TDD, debugging, code review...)"
echo "    - Secure code review skill (security checklist for AI-generated code)"
echo "    - Token efficiency skill (reduces API costs and verbosity)"
echo "    - Cost-saving defaults (small model for housekeeping, auto-compaction)"
echo "    - MCP servers: Context7 (docs), Grep (code search), Cloudflare Docs"
echo "    - Safe permission defaults for git and shell commands"
echo ""
echo "  Next steps:"
echo "    1. Open a NEW terminal window (or run: source ~/.zshrc)"
echo "    2. Type 'oc' to launch OpenCode"
echo "    3. If you skipped the API key step, run /connect inside OpenCode"
echo ""
echo "  Useful commands inside OpenCode:"
echo "    /connect    — set up or change your LLM provider"
echo "    /models     — switch between AI models"
echo "    /init       — analyze a project and create AGENTS.md"
echo "    /help       — see all commands"
echo ""
echo "  Docs: https://opencode.ai/docs"
echo ""
echo "========================================"
echo ""
