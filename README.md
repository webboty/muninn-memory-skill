# Muninn Memory Skill

A cognitive memory system for AI agents using MuninnDB - the world's first cognitive database with temporal priority, Hebbian learning, and automatic association building.

## What This Skill Does

This skill enables AI agents to store and retrieve memories using MuninnDB's cognitive memory capabilities:

- **Remember** - Store important information with concepts, tags, and confidence levels
- **Recall** - Find relevant memories using cognitive search (not just keyword matching)
- **Extract Session Insights** - Harvest key learnings from conversations
- **Manage Vaults** - Organize memories into project-specific vaults

## Installation

### Option 1: Via npx (recommended)
```bash
npx add-skill https://github.com/webboty/muninn-memory-skill
```

### Option 2: Manual Installation
```bash
# Clone the repository
git clone https://github.com/webboty/muninn-memory-skill.git ~/.opencode/skill/muninn-memory

# Copy example configs and customize
cp ~/.opencode/skill/muninn-memory/examples/config.json.example ~/.opencode/skill/muninn-memory/config.json
```

## Features

### Cognitive Memory
- **Temporal Priority** - Frequently accessed memories rank higher over time
- **Hebbian Learning** - Memories recalled together build associations automatically
- **ACT-R Scoring** - Deterministic, mathematical relevance scoring
- **No Embeddings Required** - Works with BM25 full-text search

### Multi-Vault Support
- Separate vaults for different projects
- Project-to-vault mapping based on working directory
- API key authentication per vault

### Security
- API keys stored in separate vault config files (not in main config)
- Keys never exposed to the LLM - used only in local curl commands
- Bearer token authentication

## Quick Start

### 1. Configure the Skill

```bash
# Set your API endpoint
~/.opencode/skill/muninn-memory/config.sh set-api-endpoint http://localhost:8475

# Set your default vault
~/.opencode/skill/muninn-memory/config.sh set-default-vault default

# Map a project to a vault
~/.opencode/skill/muninn-memory/config.sh add-project "my-project" "my-project"
```

### 2. Add Vaults & API Keys

```bash
# Create vault config (without key first)
~/.opencode/skill/muninn-memory/vaults.sh create my-project

# Add API key (generate via muninn CLI: muninn api-key create --vault my-project)
~/.opencode/skill/muninn-memory/vaults.sh add-key my-project "mk_your_key_here"
```

### 3. Use It

The skill activates when you say things like:
- "remember that..." / "store this..."
- "recall memories about..."
- "what do you know about..."
- "extract memories from this session"

## Commands Reference

### Config Management
```bash
~/.opencode/skill/muninn-memory/config.sh show                    # Show config
~/.opencode/skill/muninn-memory/config.sh set-api-endpoint <url>   # Set API endpoint
~/.opencode/skill/muninn-memory/config.sh set-preference <api|mcp> # API or MCP
~/.opencode/skill/muninn-memory/config.sh set-default-vault <v>   # Set default vault
~/.opencode/skill/muninn-memory/config.sh add-project <p> <v>      # Project → vault
```

### Vault Management
```bash
~/.opencode/skill/muninn-memory/vaults.sh list              # List vaults
~/.opencode/skill/muninn-memory/vaults.sh create <vault>    # Create vault config
~/.opencode/skill/muninn-memory/vaults.sh add-key <v> <key> # Add API key
~/.opencode/skill/muninn-memory/vaults.sh remove <vault>    # Remove vault
~/.opencode/skill/muninn-memory/vaults.sh show <vault>      # Show vault details
```

## MuninnDB Endpoints

| Protocol | Port | Use Case |
|----------|------|----------|
| REST     | 8475 | API calls |
| Web UI   | 8476 | Browser dashboard |
| MCP      | 8750 | AI agent tools |

## Memory Fields

| Field | Type | Description |
|-------|------|-------------|
| concept | string | Short label (what it's about) |
| content | string | The memory itself |
| tags | array | Labels for filtering |
| confidence | float | 0.0-1.0 certainty |
| type | string | fact, decision, observation, preference, issue, task |

## Examples

### Store a Memory
```bash
curl -s http://localhost:8475/api/engrams \
  -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer mk_xxx..." \
  -d '{
    "vault": "my-project",
    "concept": "user preference",
    "content": "User prefers dark mode",
    "tags": ["preference", "ui"],
    "confidence": 0.9,
    "type": "preference"
  }'
```

### Recall Memories
```bash
curl -s http://localhost:8475/api/activate \
  -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer mk_xxx..." \
  -d '{
    "context": ["user preferences"],
    "vault": "my-project",
    "limit": 5
  }'
```

## File Structure

```
muninn-memory/
├── SKILL.md              # This file
├── config.json           # Main config (copy from examples)
├── config.sh             # Config manager script
├── vaults/               # Vault configs (API keys here)
│   └── default.json      # Example vault config (copy from examples)
└── examples/             # Example files (remove real data)
    ├── config.json.example
    └── vault.json.example
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
