#!/bin/bash
# Muninn Vault Manager - handles vault CRUD and API key management
# Stores vault configs in ~/.opencode/skill/muninn-memory/vaults/

CONFIG_DIR="$HOME/.opencode/skill/muninn-memory"
VAULTS_DIR="$CONFIG_DIR/vaults"
CONFIG_FILE="$CONFIG_DIR/config.json"

mkdir -p "$VAULTS_DIR"

# Load config
get_config() {
    jq -r ".$1" "$CONFIG_FILE" 2>/dev/null
}

# Get vault config
get_vault_config() {
    local vault="$1"
    cat "$VAULTS_DIR/$vault.json" 2>/dev/null
}

# Get API key for vault
get_vault_key() {
    local vault="$1"
    jq -r ".api_key" "$VAULTS_DIR/$vault.json" 2>/dev/null
}

# Show all vaults
list_vaults() {
    echo "Configured vaults:"
    for f in "$VAULTS_DIR"/*.json; do
        if [ -f "$f" ]; then
            name=$(basename "$f" .json)
            key=$(jq -r ".api_key" "$f")
            if [ -n "$key" ]; then
                echo "  $name (key: ${key:0:10}...)"
            else
                echo "  $name (no key)"
            fi
        fi
    done
}

# Create vault with API key
create_vault() {
    local vault="$1"
    local label="${2:-opencode}"
    
    if [ -z "$vault" ]; then
        echo "Usage: create_vault <vault-name> [label]"
        return 1
    fi
    
    if [ -f "$VAULTS_DIR/$vault.json" ]; then
        echo "Vault '$vault' already exists"
        return 1
    fi
    
    # Create vault via API (need admin auth)
    local admin_user=$(get_config "admin.username")
    echo "Creating vault '$vault'..."
    
    # For now, just create the vault config file
    # The API key would need to be generated via muninn CLI
    cat > "$VAULTS_DIR/$vault.json" << EOF
{
  "name": "$vault",
  "api_key": "",
  "label": "$label",
  "created": "$(date -Iseconds)"
}
EOF
    
    echo "Vault '$vault' created. Add API key with: add_key $vault <key>"
}

# Add/update API key for vault
add_key() {
    local vault="$1"
    local key="$2"
    
    if [ -z "$vault" ] || [ -z "$key" ]; then
        echo "Usage: add_key <vault-name> <api-key>"
        return 1
    fi
    
    if [ ! -f "$VAULTS_DIR/$vault.json" ]; then
        echo "Vault '$vault' does not exist. Create it first."
        return 1
    fi
    
    local tmp=$(mktemp)
    jq ".api_key = \"$key\"" "$VAULTS_DIR/$vault.json" > "$tmp" && mv "$tmp" "$VAULTS_DIR/$vault.json"
    echo "API key added for vault '$vault'"
}

# Remove vault
remove_vault() {
    local vault="$1"
    
    if [ -z "$vault" ]; then
        echo "Usage: remove_vault <vault-name>"
        return 1
    fi
    
    if [ ! -f "$VAULTS_DIR/$vault.json" ]; then
        echo "Vault '$vault' does not exist"
        return 1
    fi
    
    rm "$VAULTS_DIR/$vault.json"
    echo "Vault '$vault' removed from config"
}

# Get vault for project
get_vault_for_project() {
    local project="$1"
    local default_vault=$(get_config "default_vault")
    
    # Check project_vaults mapping
    local mapped=$(jq -r ".project_vaults.\"$project\" // empty" "$CONFIG_FILE")
    
    if [ -n "$mapped" ]; then
        echo "$mapped"
    elif [ -f "$VAULTS_DIR/$project.json" ]; then
        echo "$project"
    else
        echo "$default_vault"
    fi
}

# Get auth header for vault
get_auth_header() {
    local vault="$1"
    local key=$(get_vault_key "$vault")
    
    if [ -n "$key" ]; then
        echo "Authorization: Bearer $key"
    fi
}

# Show vault details
show_vault() {
    local vault="$1"
    
    if [ ! -f "$VAULTS_DIR/$vault.json" ]; then
        echo "Vault '$vault' not found"
        return 1
    fi
    
    cat "$VAULTS_DIR/$vault.json" | jq '
        .api_key = (if .api_key == "" then "(none)" else .api_key[:20] + "..." end)
    '
}

case "${1:-}" in
    list) list_vaults ;;
    create) create_vault "$2" "$3" ;;
    add-key) add_key "$2" "$3" ;;
    remove) remove_vault "$2" ;;
    show) show_vault "$2" ;;
    get-vault) get_vault_for_project "$2" ;;
    get-key) get_vault_key "$2" ;;
    get-auth) get_auth_header "$2" ;;
    *) 
        echo "Muninn Vault Manager"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  list                List all configured vaults"
        echo "  create <v> [label]  Create new vault config"
        echo "  add-key <v> <key>  Add API key to vault"
        echo "  remove <v>         Remove vault from config"
        echo "  show <v>           Show vault details"
        echo "  get-vault <proj>   Get vault for project"
        echo "  get-key <v>        Get API key for vault"
        echo "  get-auth <v>       Get Authorization header"
        ;;
esac
