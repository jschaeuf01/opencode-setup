# OpenCode Setup — Agent Instructions

This repo contains a macOS setup script for OpenCode and bundled agent skills.
It is NOT a software project — it is an installer and skill distribution repo.

## Repo Purpose

Provide a one-command setup for OpenCode on a personal Mac, including:
- Dev tool installation (Homebrew, git, jq, Node.js, Docker)
- OpenCode installation and configuration
- Superpowers plugin registration
- Custom skill installation (security review, token efficiency)

## Repo Structure

```
setup-opencode.sh                     # Main installer script (bash, macOS)
skills/                               # Custom skills bundled with this repo
  secure-code-review/SKILL.md         # Security checklist for AI-generated code
  token-efficiency/SKILL.md           # Cost control and token usage discipline
README.md                             # User-facing documentation
AGENTS.md                             # This file — agent instructions
```

## Architecture

### setup-opencode.sh

A single idempotent bash script with 8 sequential steps:

1. Install Homebrew (+ persist PATH to ~/.zshrc)
2. Install dev tools (git, jq, Node.js)
3. Install Docker Desktop
4. Install OpenCode CLI (brew, fallback to curl installer)
5. Write ~/.config/opencode/opencode.jsonc (MCP servers, plugins, permissions)
6. Install bundled skills from skills/ to ~/.config/opencode/skills/
7. Prompt for LLM API key (Anthropic/OpenAI/OpenRouter) and persist to ~/.zshrc
8. Add `oc` launcher function to ~/.zshrc

The script is designed for non-technical users. It:
- Checks for root (refuses to run as sudo)
- Checks for macOS (exits with guidance on Linux)
- Uses color-coded output for status
- Skips anything already installed (idempotent)
- Never overwrites existing opencode.jsonc config

### Skills

Skills live in `skills/<name>/SKILL.md` and follow the OpenCode agent skills
format (YAML frontmatter with `name` and `description`, markdown body).

The setup script copies skills to `~/.config/opencode/skills/` so OpenCode
auto-discovers them globally.

### Config (opencode.jsonc)

The generated config includes:
- **Superpowers plugin** — installed from git via OpenCode's plugin manager
- **MCP servers** — Context7 (docs search), Grep by Vercel (code search),
  Cloudflare Docs (CF product docs). All free, no auth required.
- **Permissions** — safe defaults. Read-only git commands auto-allowed,
  destructive git/shell commands require confirmation or are denied.

## Coding Standards

### Shell Script

- **Bash** with `set -u` (fail on undefined variables)
- Functions for each install step, prefixed with descriptive names
- Color output via ANSI escape codes (`green_echo`, `red_echo`, `yellow_echo`)
- Every step is idempotent — check before installing, skip if present
- Use `command -v` to test for binaries, not `which`
- Use `>/dev/null 2>&1` to suppress noisy install output
- Quote all variable expansions

### Skills

- YAML frontmatter is required: `name` (lowercase, hyphenated) and `description`
- `name` must match the containing directory name
- `description` should tell the agent WHEN to use the skill, not just what it does
- Skill body is markdown, read by the AI agent at runtime
- Keep skills focused — one concern per skill
- Use checklists for procedural skills (the agent follows them step by step)

### README

- Target audience is a non-technical Mac user
- Keep instructions copy-pasteable
- Tables for structured information
- No jargon without explanation

## Making Changes

### Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with proper frontmatter
2. The `name` field must match the directory name exactly
3. The `description` should answer: "When should the agent load this skill?"
4. Re-run `bash setup-opencode.sh` to install it (or copy manually)
5. Update README.md to document the new skill

### Modifying the setup script

- Maintain the numbered step structure (`[N/8]` prefixes)
- If adding a new step, update the total count in ALL step headers
- Every new install must be idempotent (check-then-install pattern)
- Test on a clean macOS machine or verify each check-before-install branch

### Modifying the config template

- The config is a heredoc in setup-opencode.sh (search for `OCEOF`)
- It uses JSONC (JSON with comments) — comments are valid
- The script will NOT overwrite an existing config file
- If the config format changes, document migration steps in README

## Testing

There are no automated tests. Verification is manual:
- Run on a fresh macOS install (or one where the tools are already present)
- Confirm each step reports `[OK]` for already-installed items
- Confirm skills appear in `~/.config/opencode/skills/`
- Confirm `opencode` launches and skills are discoverable via the skill tool

## Security Considerations

- The script never stores secrets in files (API keys go to ~/.zshrc as env vars)
- The opencode.jsonc permission config denies destructive git commands by default
- The secure-code-review skill is designed to catch common AI-generated
  vulnerabilities — it should be kept current with OWASP Top 10
- Never commit real API keys, tokens, or credentials to this repo
