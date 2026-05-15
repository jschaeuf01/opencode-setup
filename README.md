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

- **MCP servers** (external tools available to the AI):
  - [Context7](https://context7.com) — search library and framework docs
  - [Grep by Vercel](https://grep.app) — search GitHub code examples
  - [Cloudflare Docs](https://developers.cloudflare.com) — search Cloudflare product docs
- **Safe permission defaults** — destructive commands require confirmation
- **`oc` shortcut** — launch OpenCode by typing `oc`

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/jschaeuf01/opencode-setup/main/setup-opencode.sh -o setup-opencode.sh
bash setup-opencode.sh
```

Or clone and run:

```bash
git clone https://github.com/jschaeuf01/opencode-setup.git
cd opencode-setup
bash setup-opencode.sh
```

The script will prompt you for an LLM provider API key (Anthropic, OpenAI, or OpenRouter). You can also skip this and configure it later inside OpenCode with `/connect`.

## After setup

1. Open a **new terminal window** (or run `source ~/.zshrc`)
2. Type `oc` to launch OpenCode
3. Run `/connect` to set up or change your AI provider
4. Navigate to a project and run `/init` to get started

## Re-running

The script is idempotent — it only installs what's missing and never overwrites your existing config. Safe to re-run at any time.

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
| `~/.config/opencode/opencode.jsonc` | MCP servers + permission config |

## Links

- [OpenCode docs](https://opencode.ai/docs)
- [OpenCode GitHub](https://github.com/anomalyco/opencode)
- [OpenCode Discord](https://opencode.ai/discord)
