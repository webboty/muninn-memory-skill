# Muninn Memory Skill

A skill that adds **intelligent memory management** on top of MuninnDB for AI agents.

## What This Skill Adds on Top of MuninnDB

This skill extends MuninnDB with:

| Feature | What It Does |
|---------|--------------|
| **Session Memory Extraction** | Automatically extract key insights, decisions, and facts from conversations |
| **Smart Deduplication** | Check if memory already exists before storing |
| **Project-Based Vaults** | Auto-detect vault from working directory (e.g., `my-project/` → `my-project` vault) |
| **Config Management** | CLI tools for managing config and vaults (`config.sh`, `vaults.sh`) |
| **Security-First Design** | API keys stored separately, never exposed to the LLM |
| **Cross-Platform** | Bash scripts for macOS/Linux, PowerShell for Windows |

### What MuninnDB Already Provides

- **Cognitive Memory** - Temporal priority, Hebbian learning, ACT-R scoring
- **Multi-Vault** - Isolated namespaces per project
- **REST API** - Port 8475 for storage/retrieval
- **MCP Tools** - Native integration with Claude, Cursor, etc.

This skill wraps MuninnDB with **workflow automation** and **security** that MuninnDB doesn't provide out of the box.

### Auto-Setup agents.md

This skill can also set up your project's `agents.md` with MuninnDB instructions:

```bash
# Add MuninnDB instructions to agents.md in current directory
~/.opencode/skill/muninn-memory/scripts/setup-agents-md.sh

# Or specify a directory
~/.opencode/skill/muninn-memory/scripts/setup-agents-md.sh /path/to/project
```

This will:
1. Create `agents.md` if it doesn't exist
2. Append MuninnDB instructions if `agents.md` exists but doesn't have them
3. Skip if MuninnDB section already present

The instructions tell agents to proactively check MuninnDB before answering questions.

## Installation

### Option 1: Via npx (recommended)
```bash
npx skills add webboty/muninn-memory-skill
```

### Option 2: Manual Installation
```bash
# Clone the repository
git clone https://github.com/webboty/muninn-memory-skill.git ~/.opencode/skill/muninn-memory

# Copy example configs and customize
cp ~/.opencode/skill/muninn-memory/examples/config.json.example ~/.opencode/skill/muninn-memory/config.json
```

## After Installation - Required Setup

After installing the skill, you MUST create config files. The skill will not work without them:

### 1. Create main config
```bash
# Find where the skill is installed (depends on agent)
# Common locations:
# - ~/.agents/skills/muninn-memory/
# - ~/.opencode/skill/muninn-memory/
# - .agents/skills/muninn-memory/

# Copy and edit the example
cp examples/config.json.example config.json
```

### 2. Edit config.json
```bash
# Set your API endpoint
./config.sh set-api-endpoint http://localhost:8475

# Or manually edit config.json:
# - api.endpoint: your MuninnDB URL
# - default_vault: vault name to use by default
```

### 3. Create vault configs
```bash
# Create a vault config
./vaults.sh create my-vault

# Add your API key (generate via: muninn api-key create --vault my-vault)
./vaults.sh add-key my-vault "mk_your_key_here"
```

### 4. Map projects to vaults (optional)
```bash
./config.sh add-project "my-project" "my-vault"
```

## Quick Start

**Note:** The skill may be installed in different locations depending on the agent. Common paths:
- `~/.agents/skills/muninn-memory/` (npx install)
- `~/.opencode/skill/muninn-memory/` (manual)
- `.agents/skills/muninn-memory/` (project local)

Replace `<skill-dir>` below with your actual installation path.

### 1. Configure the Skill
```bash
# Set your API endpoint
<skill-dir>/config.sh set-api-endpoint http://localhost:8475

# Set your default vault
<skill-dir>/config.sh set-default-vault default

# Map a project to a vault
<skill-dir>/config.sh add-project "my-project" "my-project"
```

### 2. Add Vaults & API Keys
```bash
# Create vault config
<skill-dir>/vaults.sh create my-project

# Add API key (generate via: muninn api-key create --vault my-project)
<skill-dir>/vaults.sh add-key my-project "mk_your_key_here"
```

### 3. Use It

The skill activates when you say:
- "remember that..." / "store this..."
- "recall memories about..."
- "extract memories from this session"
- "what do you know about..."

## Key Features Explained

### Session Memory Extraction

When you say "extract memories from this session", the skill:
1. Gathers recent conversation context
2. Analyzes for decisions, facts, preferences, insights
3. **Checks for duplicates** before storing
4. Stores to the correct vault based on project

### Project-Based Vaults

The skill automatically resolves the right vault:
1. User specifies explicitly: "save to project-x vault"
2. Detects from working directory: `/path/to/my-project/` → `my-project` vault
3. Falls back to default vault

### Security-First Design

- API keys stored in `vaults/*.json` (not in main config)
- Keys injected via bash at runtime - LLM never sees them
- `.gitignore` excludes real config files from git

## Commands Reference

### Config Management
```bash
<skill-dir>/config.sh show                    # Show config
<skill-dir>/config.sh set-api-endpoint <url> # API endpoint
<skill-dir>/config.sh set-preference <api|mcp> # Engine preference
<skill-dir>/config.sh set-default-vault <v>   # Default vault
<skill-dir>/config.sh add-project <p> <v>      # Project → vault mapping
```

### Vault Management
```bash
<skill-dir>/vaults.sh list              # List vaults
<skill-dir>/vaults.sh create <vault>    # Create vault config
<skill-dir>/vaults.sh add-key <v> <key> # Add API key
<skill-dir>/vaults.sh remove <vault>    # Remove vault
<skill-dir>/vaults.sh show <vault>      # Show vault details
```

### Vault Management
```bash
vaults.sh list              # List vaults
vaults.sh create <vault>    # Create vault config
vaults.sh add-key <v> <key> # Add API key
vaults.sh remove <vault>    # Remove vault
vaults.sh show <vault>      # Show vault details
```

## MuninnDB Endpoints

| Protocol | Port | Use Case |
|----------|------|----------|
| REST     | 8475 | API calls |
| Web UI   | 8476 | Browser dashboard |
| MCP      | 8750 | AI agent tools |

## File Structure

**Where the skill is installed** (varies by agent):
- `~/.agents/skills/muninn-memory/` (via `npx skills add`)
- `~/.opencode/skill/muninn-memory/` (manual install)
- `.agents/skills/muninn-memory/` (project-local)

```
muninn-memory/
├── SKILL.md              # Skill instructions (for AI agent)
├── README.md             # This file (for humans)
├── config.sh             # Config manager (Bash)
├── vaults.sh            # Vault manager (Bash)
├── scripts/
│   ├── check.ps1        # Health check (PowerShell)
│   ├── config.ps1        # Config manager (PowerShell)
│   └── vaults.ps1       # Vault manager (PowerShell)
├── vaults/               # Vault configs (API keys here)
└── examples/            # Example configs
    ├── config.json.example
    └── vault.json.example
```

## Windows Support

On Windows, use WSL or PowerShell scripts in `scripts/`:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\check.ps1
powershell -ExecutionPolicy Bypass -File scripts\config.ps1 show
```

## Security Notes

- **Never commit real API keys** - Use `.gitignore` to exclude `config.json` and `vaults/`
- **Keys stay local** - The LLM uses keys via bash/curl, never sees them directly
- **Separate configs** - Vault-specific keys are in `vaults/*.json`, not in main config

## Requirements

- MuninnDB running (v0.3.6+)
- Access to REST API (port 8475)
- API keys for vault authentication (or dev mode without auth)

## License

MIT License - Feel free to use and modify!

## Links

- [MuninnDB](https://muninndb.com)
- [Skill Repository](https://github.com/webboty/muninn-memory-skill)
