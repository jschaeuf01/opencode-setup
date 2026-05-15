# OpenCode Setup

Set up [OpenCode](https://opencode.ai) on your Mac or Windows PC in about 5 minutes. OpenCode is a free, open source AI coding assistant that runs in your terminal. Think of it like ChatGPT, but it can read, write, and run your code directly.

This repo has scripts for both platforms — just follow the steps for yours below.

- **Mac?** Jump to [Mac Setup](#mac-setup)
- **Windows?** Jump to [Windows Setup](#windows-setup)

> **What's an API key?** It's like a password that lets OpenCode talk to an AI service (like Claude or ChatGPT). You get one by creating a free account with a provider. Both scripts will walk you through this — you can also set it up later.

---

# Mac Setup

## What You Need Before Starting

- A Mac (any recent macOS version)
- Your Mac login password (the script may ask for it once during setup)
- An internet connection
- An API key from an AI provider (optional — the script will help you set one up)

---

## Installation — Step by Step

### Step 1: Open Terminal

Press **Command + Space** on your keyboard, type **Terminal**, and press **Enter**. A window with a blinking cursor will appear — this is where you'll paste the commands below.

### Step 2: Download this setup

Copy the entire block below, paste it into Terminal, and press **Enter**:

```bash
git clone https://github.com/jschaeuf01/opencode-setup.git
```

> **If you see an error about `git`:** That's OK — it means developer tools aren't installed yet. A popup will appear asking you to install them. Click **Install**, wait for it to finish (can take 5-10 min), then try the command again.

### Step 3: Go into the folder

```bash
cd opencode-setup
```

### Step 4: Run the setup script

```bash
bash setup-opencode.sh
```

The script will now:
1. Install [Homebrew](https://brew.sh) (a tool installer for Mac) — if you're asked for your password, type your Mac login password and press Enter. You won't see characters as you type — that's normal.
2. Install developer tools (Git, Node.js, jq)
3. Install [Docker Desktop](https://docker.com) (lets you run apps in containers)
4. Install OpenCode
5. Set up configuration and AI skills
6. Ask you to choose an AI provider (or skip for later)
7. Create the `oc` shortcut command

**This takes 3-10 minutes** depending on your internet speed and whether tools are already installed.

### Step 5: Set up your AI provider

The script will ask you to choose a provider. Here are your options:

| Option | Provider | What it is | Sign up |
|--------|----------|-----------|---------|
| **1** | Anthropic (Claude) | Best for coding. Recommended. | [console.anthropic.com](https://console.anthropic.com) |
| **2** | OpenAI (GPT) | The makers of ChatGPT | [platform.openai.com](https://platform.openai.com) |
| **3** | OpenRouter | Access many AI models in one place | [openrouter.ai](https://openrouter.ai) |
| **s** | Skip | Set it up later inside OpenCode | — |

If you choose a provider, you'll need to:
1. Create an account on their website (linked above)
2. Generate an API key (usually under "API Keys" or "Settings")
3. Paste the key when the script asks for it

> **Don't have an API key yet?** Press **s** to skip. You can set it up later by typing `/connect` inside OpenCode.

### Step 6: Open a new Terminal window

Close your current Terminal window (**Command + Q**) and open a new one (**Command + Space**, type **Terminal**, press **Enter**). This is needed so your computer picks up the new settings.

### Step 7: Launch OpenCode

Type this and press Enter:

```bash
oc
```

You should see the OpenCode interface appear. You're ready to go!

---

# Windows Setup

## What You Need Before Starting

- Windows 10 or 11
- An internet connection
- **winget** (comes pre-installed on most Windows 10/11 PCs — if not, get it from the [Microsoft Store](https://aka.ms/getwinget))
- An API key from an AI provider (optional — the script will help you set one up)

## Installation — Step by Step

### Step 1: Open PowerShell

Press **Windows key**, type **PowerShell**, and click **Windows PowerShell**. A blue window with a blinking cursor will appear.

> **Important:** Use regular PowerShell, not "Run as Administrator" (the script will ask for elevation only if needed).

### Step 2: Allow scripts to run

Copy and paste this into PowerShell and press **Enter**:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

This allows PowerShell to run downloaded scripts. You only need to do this once.

### Step 3: Download this setup

```powershell
git clone https://github.com/jschaeuf01/opencode-setup.git
```

> **If you see an error about `git`:** Install Git first by running `winget install Git.Git`, then close and reopen PowerShell, and try again.

### Step 4: Go into the folder

```powershell
cd opencode-setup
```

### Step 5: Run the setup script

```powershell
.\setup-opencode.ps1
```

The script will now:
1. Check that **winget** is available
2. Install **Git** (if not already installed)
3. Install **Node.js** (if not already installed)
4. Install **Docker Desktop** (if not already installed)
5. Install **OpenCode** via npm
6. Write the configuration file with MCP servers and permissions
7. Install the bundled skills (security review, token efficiency)
8. Ask you to choose an AI provider (or skip for later)
9. Add the `oc` shortcut to your PowerShell profile

**This takes 3-10 minutes** depending on your internet speed.

### Step 6: Set up your AI provider

Same as Mac — the script will ask you to choose Anthropic, OpenAI, OpenRouter, or skip.

### Step 7: Close and reopen PowerShell

Close the current PowerShell window and open a new one so the new settings take effect.

### Step 8: Launch OpenCode

```powershell
oc
```

You should see the OpenCode interface appear. You're ready to go!

### Windows Troubleshooting

| Problem | Fix |
|---------|-----|
| `oc: The term 'oc' is not recognized` | Close PowerShell completely and open a new one |
| `winget: The term 'winget' is not recognized` | Install App Installer from the [Microsoft Store](https://aka.ms/getwinget) |
| `scripts is disabled on this system` | Run: `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force` |
| `opencode: The term 'opencode' is not recognized` | Close and reopen PowerShell, then run: `npm install -g opencode-ai` |
| Docker isn't working | Open Docker Desktop from the Start menu to complete first-time setup. You may need to restart your PC. |
| Node.js / npm not found after install | Close and reopen PowerShell — PATH updates require a new session |
| Want to change AI provider | Run `/connect` inside OpenCode |

---

# Using OpenCode — Quick Start

> This section applies to both Mac and Windows.

Once OpenCode is running, you can just type what you want in plain English. Here are some things to try:

| What to type | What happens |
|-------------|-------------|
| `Explain what this project does` | Analyzes the current folder and explains the code |
| `Create a simple Python script that converts temperatures` | Writes code for you |
| `Fix the bug in app.js` | Reads the file, finds the issue, and fixes it |
| `Review this code for security issues` | Runs a security checklist on recent changes |
| `/connect` | Set up or change your AI provider |
| `/models` | Switch between different AI models |
| `/init` | Analyze your project and create an AGENTS.md file |
| `/help` | See all available commands |

### Working on a project

To use OpenCode on one of your projects, first navigate to it:

```bash
cd ~/path/to/your/project
oc
```

OpenCode will be able to read and modify files in that folder.

---

## What Gets Installed

The script installs these tools on your Mac:

| Tool | What it does | Why you need it |
|------|-------------|-----------------|
| [Homebrew](https://brew.sh) | Installs other tools for you | Required to install everything else |
| Git | Tracks code changes | Used by OpenCode and most dev workflows |
| Node.js | Runs JavaScript | Required by OpenCode and many dev tools |
| jq | Reads JSON files | Used by scripts and configs |
| [Docker Desktop](https://docker.com) | Runs apps in containers | Test and deploy without messing up your Mac |
| [OpenCode](https://opencode.ai) | AI coding assistant | The main tool |

## What Gets Configured

### AI Skills

Skills teach OpenCode good development practices. They activate automatically — you don't need to do anything special.

**[Superpowers](https://github.com/obra/superpowers)** (installed automatically on first launch):

| Skill | What it does |
|-------|-------------|
| Brainstorming | Asks clarifying questions before jumping into code |
| Test-driven development | Writes tests before writing the actual code |
| Systematic debugging | Diagnoses problems methodically instead of guessing |
| Verification | Proves code works by running it before claiming "done" |
| Writing plans | Breaks big tasks into clear, manageable steps |
| Code review | Reviews code quality before you commit |

**Secure code review** (installed by this script):

Checks every piece of code for common security mistakes that AI tends to make, including:
- SQL injection, cross-site scripting (XSS), and other attack vectors
- Hardcoded passwords or API keys left in code
- Missing input validation
- Weak encryption or authentication
- And more (based on the [OWASP Top 10](https://owasp.org/www-project-top-ten/))

**Token efficiency** (installed by this script):

Keeps your API costs low by teaching OpenCode to:
- Not re-read files it already has in context
- Read only the lines it needs, not entire files
- Give concise answers instead of long-winded explanations
- Make multiple tool calls at once instead of one at a time
- Stop exploring when it has enough information to act

### Cost Control Settings

The config includes several settings that reduce how many tokens (and dollars) OpenCode uses:

| Setting | What it does | Why it saves money |
|---------|-------------|-------------------|
| `small_model` | Uses a cheap model for small tasks like naming sessions | You're not paying for Claude Opus to generate a title |
| `compaction.auto` | Automatically summarizes long conversations | Prevents context from growing until it hits the limit and errors out |
| `compaction.prune` | Removes old tool outputs | Frees up space without losing the important parts |
| `share: disabled` | Disables session sharing | No extra API calls to upload conversations |
| `autoupdate: true` | Updates OpenCode on launch | Keeps you on the latest (most efficient) version |

**Tip:** You can also control costs from your provider's dashboard. Most providers let you set monthly spending limits (e.g., $10/month on Anthropic).

### Tool Integrations (MCP Servers)

These give OpenCode the ability to search external resources:

| Tool | What it searches | Auth needed? |
|------|-----------------|-------------|
| [Context7](https://context7.com) | Library and framework documentation | No |
| [Grep by Vercel](https://grep.app) | Real code examples on GitHub | No |
| [Cloudflare Docs](https://developers.cloudflare.com) | Cloudflare product docs (Workers, Pages, R2, etc.) | No |

### Safety Settings

The script configures OpenCode to ask for your permission before running potentially dangerous commands:

- **Allowed automatically:** Reading files, viewing git status/logs/diffs
- **Asks you first:** Committing code, pushing to GitHub, running `sudo`, deleting files
- **Blocked entirely:** Force-pushing, hard resetting git, deleting your home directory

You can change these settings anytime by editing `~/.config/opencode/opencode.jsonc`.

---

## Mac Troubleshooting

| Problem | Fix |
|---------|-----|
| `oc: command not found` | Close Terminal completely (**Command + Q**) and open a new one |
| `git: command not found` | A popup should appear to install Xcode tools — click Install, then retry |
| Script asks for password | Type your Mac login password and press Enter (you won't see characters — that's normal) |
| Script takes a long time | First-time Xcode Command Line Tools install can take 10-20 min. Let it finish. |
| `opencode: command not found` | Re-run the setup: `cd opencode-setup && bash setup-opencode.sh` |
| Docker isn't working | Open Docker Desktop from your Applications folder to complete its first-time setup |
| Want to change AI provider | Run `/connect` inside OpenCode |
| Want to change AI model | Run `/models` inside OpenCode |

---

## Keeping OpenCode Updated

OpenCode **updates itself automatically** every time you launch it. You don't need to do anything — when a new version is available, it downloads and installs it in the background before your session starts.

This is controlled by the `autoupdate` setting in your config (enabled by default in this setup).

If you ever want to update manually or check your version:

| What | Mac | Windows |
|------|-----|---------|
| Check version | `opencode --version` | `opencode --version` |
| Manual update (Homebrew) | `brew upgrade opencode` | — |
| Manual update (npm) | `npm update -g opencode-ai` | `npm update -g opencode-ai` |
| Disable auto-update | Set `"autoupdate": false` in `~/.config/opencode/opencode.jsonc` | Same |
| Get notified only | Set `"autoupdate": "notify"` | Same |

> **Note:** If you installed via Homebrew (Mac), the built-in autoupdate may defer to Homebrew's update mechanism. Running `brew upgrade opencode` is the most reliable way to update on Mac.

---

## Re-running the Setup Script

The setup script is separate from OpenCode's autoupdate — re-running the script updates the **bundled skills** (security review, token efficiency) and installs any new tools added to the script. It won't touch your existing config or API keys.

**Mac:**
```bash
cd opencode-setup
git pull
bash setup-opencode.sh
```

**Windows:**
```powershell
cd opencode-setup
git pull
.\setup-opencode.ps1
```

---

## Files Changed on Your Computer

**Mac:**

| File | What was added |
|------|---------------|
| `~/.zshrc` | Homebrew PATH, API key, `oc` shortcut |
| `~/.config/opencode/opencode.jsonc` | OpenCode settings (MCP servers, plugins, permissions, cost controls) |
| `~/.config/opencode/skills/*/SKILL.md` | Bundled skills (security review, token efficiency) |

**Windows:**

| File | What was added |
|------|---------------|
| PowerShell profile (`$PROFILE`) | API key, `oc` shortcut |
| `~\.config\opencode\opencode.jsonc` | OpenCode settings (MCP servers, plugins, permissions, cost controls) |
| `~\.config\opencode\skills\*\SKILL.md` | Bundled skills (security review, token efficiency) |

---

## Getting an API Key (Detailed)

If you skipped the API key step during setup, here's how to set one up:

### Option A: Inside OpenCode (easiest)

1. Launch OpenCode by typing `oc`
2. Type `/connect`
3. Pick a provider from the list
4. Follow the on-screen instructions

### Option B: Anthropic (Claude) — Recommended

1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Create an account and add a payment method
3. Click **API Keys** in the left sidebar
4. Click **Create Key**, give it a name, and copy the key
5. Set the key:
   - **Mac** — Open Terminal and run:
     ```bash
     echo 'export ANTHROPIC_API_KEY="paste-your-key-here"' >> ~/.zshrc
     ```
   - **Windows** — Open PowerShell and run:
     ```powershell
     Add-Content $PROFILE '$env:ANTHROPIC_API_KEY = "paste-your-key-here"'
     ```
6. Open a new Terminal/PowerShell window, then type `oc`

### Option C: OpenAI (GPT)

1. Go to [platform.openai.com](https://platform.openai.com)
2. Create an account and add a payment method
3. Go to **API Keys** and create a new key
4. Set the key:
   - **Mac** — Open Terminal and run:
     ```bash
     echo 'export OPENAI_API_KEY="paste-your-key-here"' >> ~/.zshrc
     ```
   - **Windows** — Open PowerShell and run:
     ```powershell
     Add-Content $PROFILE '$env:OPENAI_API_KEY = "paste-your-key-here"'
     ```
5. Open a new Terminal/PowerShell window, then type `oc`

> **How much does it cost?** Most providers charge a few cents per conversation. A typical coding session costs $0.10–$1.00. You can set spending limits in your provider's dashboard.

---

## Helpful Links

- [OpenCode documentation](https://opencode.ai/docs) — Full reference
- [OpenCode Discord](https://opencode.ai/discord) — Community help
- [Superpowers skills](https://github.com/obra/superpowers) — The dev methodology plugin
- [All supported AI providers](https://opencode.ai/docs/providers/) — 75+ options
