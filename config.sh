#!/bin/bash
# Muninn Memory Config Manager

CONFIG_FILE="$HOME/.opencode/skill/muninn-memory/config.json"
VAULTS_DIR="$HOME/.opencode/skill/muninn-memory/vaults"

show_config() {
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    else
        echo '{"error": "config not found"}'
    fi
}

set_api_endpoint() {
    local endpoint="$1"
    if [ -z "$endpoint" ]; then
        echo "Usage: set-api-endpoint <endpoint>"
        return 1
    fi
    local tmp=$(mktemp)
    jq ".api.endpoint = \"$endpoint\"" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    echo "API endpoint set to: $endpoint"
}

set_admin_credentials() {
    local user="$1"
    if [ -z "$user" ]; then
        echo "Usage: set-admin-user <username>"
        return 1
    fi
    local tmp=$(mktemp)
    jq ".admin.username = \"$user\"" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    echo "Admin user set to: $user"
}

set_preference() {
    local pref="$1"
    if [ "$pref" != "api" ] && [ "$pref" != "mcp" ]; then
        echo "Usage: set-preference <api|mcp>"
        return 1
    fi
    local tmp=$(mktemp)
    jq ".preference = \"$pref\"" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    echo "Preference set to: $pref"
}

set_default_vault() {
    local vault="$1"
    if [ -z "$vault" ]; then
        echo "Usage: set-default-vault <vault-name>"
        return 1
    fi
    local tmp=$(mktemp)
    jq ".default_vault = \"$vault\"" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    echo "Default vault set to: $vault"
}

add_project_vault() {
    local project="$1"
    local vault="$2"
    if [ -z "$project" ] || [ -z "$vault" ]; then
        echo "Usage: add-project <project-name> <vault-name>"
        return 1
    fi
    local tmp=$(mktemp)
    jq ".project_vaults.\"$project\" = \"$vault\"" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    echo "Project '$project' -> vault '$vault'"
}

get_api_endpoint() {
    jq -r ".api.endpoint" "$CONFIG_FILE"
}

get_preference() {
    jq -r ".preference" "$CONFIG_FILE"
}

get_default_vault() {
    jq -r ".default_vault" "$CONFIG_FILE"
}

get_admin_user() {
    jq -r ".admin.username" "$CONFIG_FILE"
}

case "${1:-}" in
    show) show_config ;;
    set-api-endpoint) set_api_endpoint "$2" ;;
    set-admin-user) set_admin_credentials "$2" ;;
    set-preference) set_preference "$2" ;;
    set-default-vault) set_default_vault "$2" ;;
    add-project) add_project_vault "$2" "$3" ;;
    get-api-endpoint) get_api_endpoint ;;
    get-preference) get_preference ;;
    get-default-vault) get_default_vault ;;
    get-admin-user) get_admin_user ;;
    vaults) "$VAULTS_DIR/../vaults.sh" "${@:2}" ;;
    *) 
        echo "Muninn Memory Config Manager"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Config Commands:"
        echo "  show                    Show config"
        echo "  set-api-endpoint <url>  Set API endpoint"
        echo "  set-admin-user <user>   Set admin username"
        echo "  set-preference <api|mcp> Set preferred engine"
        echo "  set-default-vault <v>   Set default vault"
        echo "  add-project <p> <v>     Map project to vault"
        echo ""
        echo "Vault Commands (use: $0 vaults <command>):"
        echo "  vaults list             List vaults"
        echo "  vaults create <v> [l]   Create vault config"
        echo "  vaults add-key <v> <k>  Add API key to vault"
        echo "  vaults remove <v>       Remove vault"
        echo "  vaults show <v>         Show vault details"
        ;;
esac
