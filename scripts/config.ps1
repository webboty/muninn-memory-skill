# Muninn Memory Config Manager - PowerShell
# For Windows (or WSL)

$ConfigFile = "$HOME\.opencode\skill\muninn-memory\config.json"
$SkillDir = "$HOME\.opencode\skill\muninn-memory"

function Show-Config {
    if (Test-Path $ConfigFile) {
        Get-Content $ConfigFile | ConvertFrom-Json | ConvertTo-Json -Depth 10
    } else {
        '{"error": "config not found"}'
    }
}

function Set-ApiEndpoint {
    param([string]$Endpoint)
    if (-not $Endpoint) {
        Write-Host "Usage: Set-ApiEndpoint <endpoint>"
        return
    }
    $json = Get-Content $ConfigFile | ConvertFrom-Json
    $json.api.endpoint = $Endpoint
    $json | ConvertTo-Json | Set-Content $ConfigFile
    Write-Host "API endpoint set to: $Endpoint"
}

function Set-Preference {
    param([string]$Pref)
    if ($Pref -ne "api" -and $Pref -ne "mcp") {
        Write-Host "Usage: Set-Preference <api|mcp>"
        return
    }
    $json = Get-Content $ConfigFile | ConvertFrom-Json
    $json.preference = $Pref
    $json | ConvertTo-Json | Set-Content $ConfigFile
    Write-Host "Preference set to: $Pref"
}

function Set-DefaultVault {
    param([string]$Vault)
    if (-not $Vault) {
        Write-Host "Usage: Set-DefaultVault <vault-name>"
        return
    }
    $json = Get-Content $ConfigFile | ConvertFrom-Json
    $json.default_vault = $Vault
    $json | ConvertTo-Json | Set-Content $ConfigFile
    Write-Host "Default vault set to: $Vault"
}

function Add-ProjectVault {
    param([string]$Project, [string]$Vault)
    if (-not $Project -or -not $Vault) {
        Write-Host "Usage: Add-ProjectVault <project> <vault>"
        return
    }
    $json = Get-Content $ConfigFile | ConvertFrom-Json
    $json.project_vaults | Add-Member -NotePropertyName $Project -NotePropertyValue $Vault -Force
    $json | ConvertTo-Json | Set-Content $ConfigFile
    Write-Host "Project '$Project' -> vault '$Vault'"
}

function Get-ApiEndpoint {
    $json = Get-Content $ConfigFile | ConvertFrom-Json
    $json.api.endpoint
}

function Get-Preference {
    $json = Get-Content $ConfigFile | ConvertFrom-Json
    $json.preference
}

function Get-DefaultVault {
    $json = Get-Content $ConfigFile | ConvertFrom-Json
    $json.default_vault
}

# Simple command dispatcher
$cmd = $args[0]
switch ($cmd) {
    "show" { Show-Config }
    "set-api-endpoint" { Set-ApiEndpoint $args[1] }
    "set-preference" { Set-Preference $args[1] }
    "set-default-vault" { Set-DefaultVault $args[1] }
    "add-project" { Add-ProjectVault $args[1] $args[2] }
    "get-api-endpoint" { Get-ApiEndpoint }
    "get-preference" { Get-Preference }
    "get-default-vault" { Get-DefaultVault }
    default {
        Write-Host "Muninn Memory Config Manager (PowerShell)"
        Write-Host ""
        Write-Host "Usage: .\config.ps1 <command> [args]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  show                    Show config"
        Write-Host "  set-api-endpoint <url>   Set API endpoint"
        Write-Host "  set-preference <api|mcp> Set engine preference"
        Write-Host "  set-default-vault <v>   Set default vault"
        Write-Host "  add-project <p> <v>     Map project to vault"
    }
}
