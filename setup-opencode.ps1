<#
.SYNOPSIS
    OpenCode Setup Script (Windows)

.DESCRIPTION
    Installs OpenCode AI coding agent + common dev tools on a Windows PC.
    Run once:  .\setup-opencode.ps1
    After that: type 'oc' to launch OpenCode.

    Idempotent — safe to re-run at any time.

    What gets installed:
      - Git (via winget)
      - Node.js (via winget)
      - Docker Desktop (via winget)
      - OpenCode CLI (via npm)

    What gets configured:
      - ~/.config/opencode/opencode.jsonc (MCP servers, plugins, permissions)
      - PowerShell profile (API key env var, 'oc' alias)

.NOTES
    Requires Windows 10/11 with winget (App Installer) available.
    Run from a regular PowerShell window — the script will request
    elevation only if needed for specific installs.
#>

$ErrorActionPreference = "Stop"

# --- Formatting ---
function Write-Green  { param([string]$msg) Write-Host $msg -ForegroundColor Green }
function Write-Red    { param([string]$msg) Write-Host $msg -ForegroundColor Red }
function Write-Yellow { param([string]$msg) Write-Host $msg -ForegroundColor Yellow }

# --- Variables ---
$ConfigDir  = Join-Path $env:USERPROFILE ".config\opencode"
$ConfigFile = Join-Path $ConfigDir "opencode.jsonc"
$SkillsDir  = Join-Path $ConfigDir "skills"
$Profile_   = $PROFILE  # PowerShell profile path

# Determine where our bundled skills live (relative to this script)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSrc = Join-Path $ScriptDir "skills"

# -------------------------------------------
# Safety checks
# -------------------------------------------
Write-Host ""
Write-Host "========================================"
Write-Green "  OpenCode Setup — Personal Edition (Windows)"
Write-Host "========================================"
Write-Host ""

# Check for winget
Write-Host "[1/8] Checking package manager..."
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Green "  [OK] winget is available."
} else {
    Write-Red "  [FAIL] winget not found."
    Write-Host "  winget comes with App Installer from the Microsoft Store."
    Write-Host "  Install it from: https://aka.ms/getwinget"
    exit 1
}

# -------------------------------------------
# Step 2: Install Git
# -------------------------------------------
Write-Host ""
Write-Host "[2/8] Checking Git..."

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Green "  [OK] Git already installed."
} else {
    Write-Yellow "  Installing Git..."
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    # Refresh PATH for current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Green "  [OK] Git installed."
    } else {
        Write-Yellow "  [WARN] Git installed but not in PATH yet. You may need to restart PowerShell."
    }
}

# -------------------------------------------
# Step 3: Install Node.js
# -------------------------------------------
Write-Host ""
Write-Host "[3/8] Checking Node.js..."

if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Green "  [OK] Node.js already installed ($(node --version))."
} else {
    Write-Yellow "  Installing Node.js..."
    winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Green "  [OK] Node.js installed."
    } else {
        Write-Yellow "  [WARN] Node.js installed but not in PATH yet. You may need to restart PowerShell."
    }
}

# -------------------------------------------
# Step 4: Install Docker Desktop
# -------------------------------------------
Write-Host ""
Write-Host "[4/8] Checking Docker..."

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Green "  [OK] Docker already installed."
} else {
    Write-Yellow "  Installing Docker Desktop..."
    Write-Host "  (This may take a few minutes)"
    winget install --id Docker.DockerDesktop -e --source winget --accept-package-agreements --accept-source-agreements
    Write-Green "  [OK] Docker Desktop installed."
    Write-Yellow "  NOTE: You may need to restart your computer and then open Docker Desktop to finish setup."
}

# -------------------------------------------
# Step 5: Install OpenCode
# -------------------------------------------
Write-Host ""
Write-Host "[5/8] Checking OpenCode..."

if (Get-Command opencode -ErrorAction SilentlyContinue) {
    Write-Green "  [OK] OpenCode already installed."
} else {
    Write-Yellow "  Installing OpenCode via npm..."
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        npm install -g opencode-ai 2>$null
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        if (Get-Command opencode -ErrorAction SilentlyContinue) {
            Write-Green "  [OK] OpenCode installed."
        } else {
            Write-Red "  [FAIL] OpenCode installed via npm but not found in PATH."
            Write-Host "  Try closing and reopening PowerShell, then run: opencode"
        }
    } else {
        Write-Red "  [FAIL] npm not available. Node.js may need a PowerShell restart."
        Write-Host "  After restarting PowerShell, run: npm install -g opencode-ai"
    }
}

# -------------------------------------------
# Step 6: Write OpenCode config
# -------------------------------------------
Write-Host ""
Write-Host "[6/8] Configuring OpenCode..."

if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

if (Test-Path $ConfigFile) {
    Write-Green "  [OK] Config already exists at $ConfigFile, skipping."
    Write-Host "  (Delete it and re-run to regenerate.)"
} else {
    $ConfigContent = @'
{
  "$schema": "https://opencode.ai/config.json",
  "share": "disabled",

  "small_model": "anthropic/claude-haiku-4-5",

  "compaction": {
    "auto": true,
    "prune": true,
    "reserved": 10000
  },

  "plugin": [
    "superpowers@git+https://github.com/obra/superpowers.git"
  ],

  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    },
    "gh_grep": {
      "type": "remote",
      "url": "https://mcp.grep.app",
      "enabled": true
    },
    "cloudflare-docs": {
      "type": "remote",
      "url": "https://docs.mcp.cloudflare.com/mcp",
      "enabled": true
    }
  },

  "permission": {
    "edit": "allow",
    "webfetch": "allow",
    "bash": {
      "*": "allow",
      "rm *": "ask",
      "rm -rf ~*": "deny",
      "rm -rf /*": "deny",
      "del /s /q *": "ask",
      "rd /s /q *": "deny",
      "Remove-Item *": "ask",
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
'@
    Set-Content -Path $ConfigFile -Value $ConfigContent -Encoding UTF8
    Write-Green "  [OK] Config written to $ConfigFile"
}

# -------------------------------------------
# Step 7: Install bundled skills
# -------------------------------------------
Write-Host ""
Write-Host "[7/8] Setting up skills..."

# Superpowers check
if (Test-Path $ConfigFile) {
    $configText = Get-Content $ConfigFile -Raw
    if ($configText -match "superpowers") {
        Write-Green "  [OK] Superpowers plugin configured (auto-installs on first launch)."
        Write-Host "  Includes: brainstorming, TDD, systematic-debugging, writing-plans,"
        Write-Host "  executing-plans, code-review, parallel-agents, verification."
    }
}

# Copy bundled skills
if (Test-Path $SkillsSrc) {
    if (-not (Test-Path $SkillsDir)) {
        New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
    }
    $skillFolders = Get-ChildItem -Path $SkillsSrc -Directory
    foreach ($folder in $skillFolders) {
        $skillFile = Join-Path $folder.FullName "SKILL.md"
        if (Test-Path $skillFile) {
            $destDir = Join-Path $SkillsDir $folder.Name
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item -Path $skillFile -Destination (Join-Path $destDir "SKILL.md") -Force
            Write-Green "  [OK] Installed skill: $($folder.Name)"
        }
    }
} else {
    Write-Yellow "  [INFO] No bundled skills directory found."
    Write-Host "  To install custom skills, clone the repo and re-run the script."
}

# -------------------------------------------
# Step 8: API key + oc alias in PowerShell profile
# -------------------------------------------
Write-Host ""
Write-Host "[8/8] Setting up LLM provider and 'oc' shortcut..."

# Ensure PowerShell profile exists
$profileDir = Split-Path -Parent $Profile_
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (-not (Test-Path $Profile_)) {
    New-Item -ItemType File -Path $Profile_ -Force | Out-Null
}

$profileContent = Get-Content $Profile_ -Raw -ErrorAction SilentlyContinue

# Check for existing API key
$apiKeySet = $false
if ($profileContent -match "ANTHROPIC_API_KEY|OPENAI_API_KEY|OPENROUTER_API_KEY") {
    Write-Green "  [OK] API key already configured in PowerShell profile."
    $apiKeySet = $true
}

if (-not $apiKeySet) {
    Write-Host ""
    Write-Host "  OpenCode needs an API key from an LLM provider."
    Write-Host "  Recommended: Anthropic (Claude) -- https://console.anthropic.com/"
    Write-Host "  Alternatives: OpenAI, OpenRouter, or use /connect in OpenCode later."
    Write-Host ""
    Write-Host "  Which provider?"
    Write-Host "    1) Anthropic (Claude) -- recommended"
    Write-Host "    2) OpenAI (GPT)"
    Write-Host "    3) OpenRouter (multi-provider)"
    Write-Host "    s) Skip -- I'll set it up later"
    Write-Host ""
    $choice = Read-Host "  Choose [1/2/3/s]"

    switch ($choice) {
        "1" {
            $apiKey = Read-Host "  Enter your Anthropic API key"
            if ($apiKey) {
                Add-Content -Path $Profile_ -Value "`n`$env:ANTHROPIC_API_KEY = `"$apiKey`""
                $env:ANTHROPIC_API_KEY = $apiKey
                Write-Green "  [OK] ANTHROPIC_API_KEY saved to PowerShell profile."
            }
        }
        "2" {
            $apiKey = Read-Host "  Enter your OpenAI API key"
            if ($apiKey) {
                Add-Content -Path $Profile_ -Value "`n`$env:OPENAI_API_KEY = `"$apiKey`""
                $env:OPENAI_API_KEY = $apiKey
                Write-Green "  [OK] OPENAI_API_KEY saved to PowerShell profile."
            }
        }
        "3" {
            $apiKey = Read-Host "  Enter your OpenRouter API key"
            if ($apiKey) {
                Add-Content -Path $Profile_ -Value "`n`$env:OPENROUTER_API_KEY = `"$apiKey`""
                $env:OPENROUTER_API_KEY = $apiKey
                Write-Green "  [OK] OPENROUTER_API_KEY saved to PowerShell profile."
            }
        }
        default {
            Write-Yellow "  Skipped. You can configure a provider later with /connect in OpenCode."
        }
    }
}

# Add 'oc' alias
if ($profileContent -notmatch "# --- OpenCode launcher") {
    $ocAlias = @"

# --- OpenCode launcher (added by setup-opencode.ps1) ---
function oc { opencode @args }
"@
    Add-Content -Path $Profile_ -Value $ocAlias
    Write-Green "  [OK] 'oc' shortcut added to PowerShell profile."
} else {
    Write-Green "  [OK] 'oc' shortcut already configured."
}

# -------------------------------------------
# Done
# -------------------------------------------
Write-Host ""
Write-Host "========================================"
Write-Green "  Setup complete!"
Write-Host "========================================"
Write-Host ""
Write-Host "  What was installed:"
Write-Host "    - Git, Node.js (dev tools)"
Write-Host "    - Docker Desktop (containers)"
Write-Host "    - OpenCode (AI coding agent)"
Write-Host ""
Write-Host "  What was configured:"
Write-Host "    - Superpowers plugin (brainstorming, TDD, debugging, code review...)"
Write-Host "    - Secure code review skill (security checklist for AI-generated code)"
Write-Host "    - Token efficiency skill (reduces API costs and verbosity)"
Write-Host "    - Cost-saving defaults (small model for housekeeping, auto-compaction)"
Write-Host "    - MCP servers: Context7 (docs), Grep (code search), Cloudflare Docs"
Write-Host "    - Safe permission defaults for git and shell commands"
Write-Host ""
Write-Host "  Next steps:"
Write-Host "    1. Close and reopen PowerShell"
Write-Host "    2. Type 'oc' to launch OpenCode"
Write-Host "    3. If you skipped the API key step, run /connect inside OpenCode"
Write-Host ""
Write-Host "  Useful commands inside OpenCode:"
Write-Host "    /connect    -- set up or change your LLM provider"
Write-Host "    /models     -- switch between AI models"
Write-Host "    /init       -- analyze a project and create AGENTS.md"
Write-Host "    /help       -- see all commands"
Write-Host ""
Write-Host "  Docs: https://opencode.ai/docs"
Write-Host ""
Write-Host "========================================"
Write-Host ""
