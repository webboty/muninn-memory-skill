---
name: muninn-memory
description: Cognitive memory skill for MuninnDB - store and retrieve memories with temporal priority, Hebbian learning, and automatic associations.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: memory-management
---

# Muninn Memory

Store and retrieve cognitive memories using MuninnDB - the cognitive database with temporal priority, Hebbian learning, and automatic association building.

## PREREQUISITE: MuninnDB Installation

Before using this skill, MuninnDB must be installed and running.

### Check if MuninnDB is installed and running:

Run the check script:
```bash
~/.opencode/skill/muninn-memory/scripts/check.sh
```

Or manually:
```bash
which muninn || ls ~/.local/bin/muninn 2>/dev/null
curl -s http://localhost:8475/api/stats 2>/dev/null || echo "not running"
```

### If NOT installed:

1. **Install MuninnDB:**
   ```bash
   curl -fsSL https://muninndb.com/install.sh | sh
   ```

2. **Start MuninnDB:**
   ```bash
   muninn start
   ```

3. **Initialize (connect AI tools):**
   ```bash
   muninn init
   ```

See: https://muninndb.com/getting-started

**IMPORTANT:** If MuninnDB is not installed, inform the user that this skill requires MuninnDB and ask if they want to install it. Provide the installation commands above.

## Configuration

Two config files:
- `config.json` - General settings (endpoint, preferences, project mappings)
- `vaults/*.json` - Per-vault settings (API keys stored separately)

### Config Manager

```bash
~/.opencode/skill/muninn-memory/config.sh show                    # Show config
~/.opencode/skill/muninn-memory/config.sh set-api-endpoint <url>  # API endpoint
~/.opencode/skill/muninn-memory/config.sh set-admin-user <user>    # Admin username
~/.opencode/skill/muninn-memory/config.sh set-preference <api|mcp> # Engine preference
~/.opencode/skill/muninn-memory/config.sh set-default-vault <v>   # Default vault
~/.opencode/skill/muninn-memory/config.sh add-project <p> <v>      # Project → vault mapping
```

### Vault Manager

```bash
~/.opencode/skill/muninn-memory/vaults.sh list              # List vaults
~/.opencode/skill/muninn-memory/vaults.sh create <vault>   # Create vault config
~/.opencode/skill/muninn-memory/vaults.sh add-key <v> <key> # Add API key to vault
~/.opencode/skill/muninn-memory/vaults.sh remove <vault>    # Remove vault
~/.opencode/skill/muninn-memory/vaults.sh show <vault>     # Show vault details
```

## Config File (config.json)

```json
{
  "api": {
    "endpoint": "http://localhost:8475",
    "timeout": 30000
  },
  "mcp": {
    "endpoint": "http://localhost:8750/mcp",
    "enabled": false
  },
  "preference": "api",
  "default_vault": "default",
  "project_vaults": {
    "Demo-Research": "demo-research"
  }
}
```

## IMPORTANT: Security - Keys Must NOT Reach the LLM

The skill makes API calls via **bash/curl** - the LLM sees the command but NOT the API key because:
1. The key is read from a **local config file** at runtime
2. The key is injected into the curl command as a variable
3. The curl command executes locally - the LLM never sees the actual key value

**CRITICAL:** Do NOT include API keys in any text output, prompts, or skill descriptions. The key only lives in the vaults/*.json files and is used directly in curl commands executed via bash.

## Vault Files (vaults/*.json)

Each vault has its own file with API key:

```json
{
  "name": "demo-research",
  "api_key": "mk_xxx...",           // API key (starts with mk_)
  "label": "Demo Research project", // Optional description
  "created": "2026-03-27T00:00:00Z"
}
```

**API keys are stored in separate files** - not in config.json - to avoid accidental exposure.

## Usage

When user wants to:
- "remember this" / "store this" - save current info to memory
- "recall memories about X" - retrieve relevant memories
- "what do you know about X" - query memory
- "extract memories from session" - harvest key insights
- "forget this" - soft-delete a memory

## Engine Selection

1. **Check preference** - Read config for `api` or `mcp`
2. **Use preferred engine** - Try that first
3. **MCP fallback** - If API fails and MCP available, try MCP tools

## Vault Resolution

**NEVER hardcode vault names.** Resolve vault in this order:

1. **User explicitly specifies** - "save to my-project vault"
2. **Project mapping** - Check `project_vaults` for current working directory
3. **Default vault** - Use `default_vault` from config

### Get Vault for Current Project
```bash
PROJECT=$(basename "$PWD")
VAULT=$(~/.opencode/skill/muninn-memory/vaults.sh get-vault "$PROJECT")
```

## API Operations

REST API is on port **8475** (not 8476 which is the web UI).

### Store Memory (with API key)

**IMPORTANT:** This curl command runs via bash tool - the LLM does NOT see the API key. The key is read from the vaults config file at execution time.

```bash
ENDPOINT=$(~/.opencode/skill/muninn-memory/config.sh get-api-endpoint)
VAULT="demo-research"
AUTH=$(~/.opencode/skill/muninn-memory/vaults.sh get-auth "$VAULT")

curl -s "$ENDPOINT/api/engrams" \
  -X POST -H "Content-Type: application/json" \
  -H "$AUTH" \
  -d "{
    \"vault\":\"$VAULT\",
    \"concept\":\"short label\",
    \"content\":\"the memory content\",
    \"tags\":[\"tag1\"],
    \"confidence\":0.9,
    \"type\":\"fact\"
  }"
```

### Recall Memories
```bash
ENDPOINT=$(~/.opencode/skill/muninn-memory/config.sh get-api-endpoint)
VAULT="demo-research"
AUTH=$(~/.opencode/skill/muninn-memory/vaults.sh get-auth "$VAULT")

curl -s "$ENDPOINT/api/activate" \
  -X POST -H "Content-Type: application/json" \
  -H "$AUTH" \
  -d "{
    \"context\": [\"search terms\"],
    \"vault\": \"$VAULT\",
    \"limit\": 10
  }"
```

### List Memories
```bash
ENDPOINT=$(~/.opencode/skill/muninn-memory/config.sh get-api-endpoint)
VAULT="demo-research"
AUTH=$(~/.opencode/skill/muninn-memory/vaults.sh get-auth "$VAULT")

curl -s "$ENDPOINT/api/engrams?vault=$VAULT" -H "$AUTH"
```

### Get Vault Stats
```bash
ENDPOINT=$(~/.opencode/skill/muninn-memory/config.sh get-api-endpoint)
AUTH=$(~/.opencode/skill/muninn-memory/vaults.sh get-auth "default")

curl -s "$ENDPOINT/api/stats" -H "$AUTH"

### Admin: Create Vault (requires admin token)
```bash
# Create via muninn CLI - generates API key automatically
muninn api-key create --vault new-vault --label opencode
```

## Auth Modes (from MuninnDB docs)

- **Development** - No auth (`auth.require_key: false`)
- **Production** - API key required (`mk_<random>`)
- **Admin** - Admin token (`mn_admin_<random>`) for vault/key management

## Memory Fields

| Field | Type | Description |
|-------|------|-------------|
| concept | string | Short label (max 512B) |
| content | string | The memory (max 16KB) |
| tags | array | Labels for filtering |
| confidence | float | 0.0-1.0 certainty |
| type | string | fact, decision, observation, preference, issue, task |

## Tips

- **Store API keys in vaults/ directory** - Not in main config
- **Use Bearer auth** - With `Authorization: Bearer mk_xxx...`
- **Deduplicate before storing** - Recall first to check duplicates
- **Project mappings in config** - Map projects to vaults in config.json
- **Admin for vault mgmt** - Create/delete vaults, generate keys via CLI
