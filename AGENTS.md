# OpenCode Setup — Agent Instructions

This repo contains setup scripts (macOS + Windows) for OpenCode and bundled
agent skills. It is NOT a software project — it is an installer and skill
distribution repo.

## Repo Purpose

Provide a one-command setup for OpenCode on a personal Mac or Windows PC:
- Dev tool installation (Homebrew/winget, git, Node.js, Docker)
- OpenCode installation and configuration
- Superpowers plugin registration
- Custom skill installation (security review, token efficiency)

## Repo Structure

```
setup-opencode.sh                     # macOS installer (bash)
setup-opencode.ps1                    # Windows installer (PowerShell)
skills/                               # Custom skills bundled with this repo
  secure-code-review/SKILL.md         # Security checklist for AI-generated code
  token-efficiency/SKILL.md           # Cost control and token usage discipline
README.md                             # User-facing documentation (both platforms)
AGENTS.md                             # This file — agent instructions
```

## Architecture

### setup-opencode.sh (macOS)

A single idempotent bash script with 8 sequential steps:

1. Install Homebrew (+ persist PATH to ~/.zshrc)
2. Install dev tools (git, jq, Node.js)
3. Install Docker Desktop (brew cask)
4. Install OpenCode CLI (brew, fallback to curl installer)
5. Write ~/.config/opencode/opencode.jsonc (MCP servers, plugins, permissions)
6. Install bundled skills from skills/ to ~/.config/opencode/skills/
7. Prompt for LLM API key (Anthropic/OpenAI/OpenRouter) and persist to ~/.zshrc
8. Add `oc` launcher function to ~/.zshrc

The script:
- Checks for root (refuses to run as sudo)
- Checks for macOS (exits with guidance on Linux)
- Uses color-coded output for status
- Skips anything already installed (idempotent)
- Never overwrites existing opencode.jsonc config

### setup-opencode.ps1 (Windows)

A single idempotent PowerShell script with 8 sequential steps:

1. Check for winget (exits with guidance if missing)
2. Install Git (winget)
3. Install Node.js LTS (winget)
4. Install Docker Desktop (winget)
5. Install OpenCode CLI (npm install -g opencode-ai)
6. Write ~/.config/opencode/opencode.jsonc (same config as macOS)
7. Install bundled skills from skills/ to ~/.config/opencode/skills/
8. Prompt for LLM API key + add `oc` function to PowerShell $PROFILE

The script:
- Does NOT require "Run as Administrator"
- Refreshes PATH after each winget install
- Uses color-coded Write-Host output for status
- Skips anything already installed (idempotent)
- Never overwrites existing opencode.jsonc config
- Adds Windows-specific permission rules (del, rd, Remove-Item)

### Shared components

Both scripts produce the **same** `opencode.jsonc` config and install the
**same** skills. The config and skills are platform-independent.

### Skills

Skills live in `skills/<name>/SKILL.md` and follow the OpenCode agent skills
format (YAML frontmatter with `name` and `description`, markdown body).

Both setup scripts copy skills to `~/.config/opencode/skills/` so OpenCode
auto-discovers them globally.

### Config (opencode.jsonc)

The generated config includes:
- **small_model** — set to claude-haiku for cheap housekeeping tasks
- **compaction** — auto-compact with pruning enabled to manage token spend
- **Superpowers plugin** — installed from git via OpenCode's plugin manager
- **MCP servers** — Context7 (docs search), Grep by Vercel (code search),
  Cloudflare Docs (CF product docs). All free, no auth required.
- **Permissions** — safe defaults. Read-only git commands auto-allowed,
  destructive git/shell commands require confirmation or are denied.

## Coding Standards

### Shell Script (macOS — setup-opencode.sh)

- **Bash** with `set -u` (fail on undefined variables)
- Functions for each install step, prefixed with descriptive names
- Color output via ANSI escape codes (`green_echo`, `red_echo`, `yellow_echo`)
- Every step is idempotent — check before installing, skip if present
- Use `command -v` to test for binaries, not `which`
- Use `>/dev/null 2>&1` to suppress noisy install output
- Quote all variable expansions

### PowerShell (Windows — setup-opencode.ps1)

- `$ErrorActionPreference = "Stop"` for fail-fast behavior
- Color output via `Write-Host -ForegroundColor` helper functions
- Every step is idempotent — use `Get-Command` to check before installing
- Use `winget install` with `--accept-package-agreements` for unattended installs
- Refresh PATH after installs: read Machine + User PATH into `$env:Path`
- OpenCode installed via `npm install -g opencode-ai` (not winget — npm is more current)
- API keys and aliases go to `$PROFILE` (PowerShell profile), not env vars

### Skills

- YAML frontmatter is required: `name` (lowercase, hyphenated) and `description`
- `name` must match the containing directory name
- `description` should tell the agent WHEN to use the skill, not just what it does
- Skill body is markdown, read by the AI agent at runtime
- Keep skills focused — one concern per skill
- Use checklists for procedural skills (the agent follows them step by step)

### README

- Target audience is a non-technical user on Mac OR Windows
- Keep instructions copy-pasteable
- Separate Mac and Windows steps clearly with headings
- Shared content (skills, cost controls, API keys) goes in platform-neutral sections
- Tables for structured information
- No jargon without explanation

## Making Changes

### Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with proper frontmatter
2. The `name` field must match the directory name exactly
3. The `description` should answer: "When should the agent load this skill?"
4. Re-run the setup script for your platform to install it (or copy manually)
5. Update README.md to document the new skill

### Modifying either setup script

- Maintain the numbered step structure (`[N/8]` prefixes)
- If adding a new step, update the total count in ALL step headers in BOTH scripts
- Every new install must be idempotent (check-then-install pattern)
- Keep both scripts in sync — same config, same skills, same step order
- The config template should be identical between the two scripts

### Modifying the config template

- macOS: heredoc in setup-opencode.sh (search for `OCEOF`)
- Windows: here-string in setup-opencode.ps1 (search for `$ConfigContent`)
- Both use JSONC (JSON with comments) — but the Windows version uses plain JSON
  since the here-string doesn't need comment support
- Neither script will overwrite an existing config file
- If the config format changes, update BOTH scripts and document migration in README

## Testing

There are no automated tests. Verification is manual:

**macOS:**
- Run on a fresh macOS install (or one where the tools are already present)
- Confirm each step reports `[OK]` for already-installed items
- Confirm skills appear in `~/.config/opencode/skills/`
- Confirm `opencode` launches and skills are discoverable via the skill tool

**Windows:**
- Run in a fresh PowerShell session on Windows 10/11
- Confirm winget, git, node, docker are detected or installed
- Confirm skills appear in `~\.config\opencode\skills\`
- Confirm `oc` function works after reopening PowerShell
- Test with and without existing PowerShell profile

## Security Considerations

- Scripts never store secrets in plaintext files (API keys go to shell profiles as env vars)
- The opencode.jsonc permission config denies destructive git commands by default
- Windows config adds Windows-specific destructive command rules (del, rd, Remove-Item)
- The secure-code-review skill is designed to catch common AI-generated
  vulnerabilities — it should be kept current with OWASP Top 10
- Never commit real API keys, tokens, or credentials to this repo
