# OpenCode Setup (macOS)

One-command setup for [OpenCode](https://opencode.ai) — an open source AI coding agent that runs in your terminal.

## What it installs

| Tool | Purpose |
|------|---------|
| [Homebrew](https://brew.sh) | macOS package manager |
| Git, jq, Node.js | Dev essentials |
| [Docker Desktop](https://docker.com) | Local containers for testing/deploying |
| [OpenCode](https://opencode.ai) | AI coding agent |

## What it configures

- **[Superpowers](https://github.com/obra/superpowers)** plugin — a complete dev methodology:
  - Brainstorming before building (design before code)
  - Test-driven development (write the test first)
  - Systematic debugging (diagnose before fixing)
  - Writing and executing implementation plans
  - Verification before completion (evidence before claims)
  - Code review workflows
  - Parallel agent coordination
- **Secure code review** skill — security checklist that catches common AI-generated vulnerabilities:
  - Injection flaws, XSS, CSRF, auth bypasses
  - Hardcoded secrets, data exposure, insecure crypto
  - Race conditions, missing access control
  - OWASP Top 10 coverage
- **MCP servers** (external tools available to the AI):
  - [Context7](https://context7.com) — search library and framework docs
  - [Grep by Vercel](https://grep.app) — search GitHub code examples
  - [Cloudflare Docs](https://developers.cloudflare.com) — search Cloudflare product docs
- **Safe permission defaults** — destructive commands require confirmation
- **`oc` shortcut** — launch OpenCode by typing `oc`

## Quick start

Clone and run (recommended — this also installs the bundled security skill):

```bash
git clone https://github.com/jschaeuf01/opencode-setup.git
cd opencode-setup
bash setup-opencode.sh
```

Or quick install (Superpowers plugin still works, but bundled skills need the clone):

```bash
curl -fsSL https://raw.githubusercontent.com/jschaeuf01/opencode-setup/main/setup-opencode.sh -o setup-opencode.sh
bash setup-opencode.sh
```

The script will prompt you for an LLM provider API key (Anthropic, OpenAI, or OpenRouter). You can also skip this and configure it later inside OpenCode with `/connect`.

## After setup

1. Open a **new terminal window** (or run `source ~/.zshrc`)
2. Type `oc` to launch OpenCode
3. Run `/connect` to set up or change your AI provider
4. Navigate to a project and run `/init` to get started

## Using the skills

Skills activate automatically when relevant. You can also load them explicitly:

```
# Ask OpenCode to review your code for security issues
review this code for security vulnerabilities

# Or load the skill directly
use skill secure-code-review
```

Superpowers skills (brainstorming, TDD, debugging, etc.) activate on their own when you ask OpenCode to build features, fix bugs, or plan implementations.

## Re-running

The script is idempotent — it only installs what's missing and never overwrites your existing config. Safe to re-run at any time. Custom skills are always updated to the latest version from the repo.

## LLM providers

OpenCode supports 75+ providers. Some popular options:

| Provider | Get API key |
|----------|-------------|
| Anthropic (Claude) | [console.anthropic.com](https://console.anthropic.com) |
| OpenAI (GPT) | [platform.openai.com](https://platform.openai.com) |
| OpenRouter | [openrouter.ai](https://openrouter.ai) |
| OpenCode Zen | [opencode.ai/auth](https://opencode.ai/auth) |

See the full list at [opencode.ai/docs/providers](https://opencode.ai/docs/providers/).

## Files modified

| File | What changes |
|------|-------------|
| `~/.zshrc` | Homebrew PATH, API key env var, `oc` function |
| `~/.config/opencode/opencode.jsonc` | MCP servers, plugins, permission config |
| `~/.config/opencode/skills/secure-code-review/SKILL.md` | Security review skill |

## Repo structure

```
opencode-setup/
  setup-opencode.sh          # Main install script
  skills/
    secure-code-review/
      SKILL.md               # Security checklist skill
  README.md
```

## Adding your own skills

Create a new directory under `skills/` with a `SKILL.md` file:

```bash
mkdir -p skills/my-skill
cat > skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What this skill does and when to use it
---

# My Skill

Instructions for the AI agent...
EOF
```

Re-run `bash setup-opencode.sh` to install it, or copy it directly to `~/.config/opencode/skills/my-skill/SKILL.md`.

## Links

- [OpenCode docs](https://opencode.ai/docs)
- [OpenCode GitHub](https://github.com/anomalyco/opencode)
- [OpenCode Discord](https://opencode.ai/discord)
- [Superpowers](https://github.com/obra/superpowers)
