# Muninn Vault Manager - PowerShell
# For Windows (or WSL)

$ConfigDir = "$HOME\.opencode\skill\muninn-memory"
$VaultsDir = "$ConfigDir\vaults"
$ConfigFile = "$ConfigDir\config.json"

function List-Vaults {
    Write-Host "Configured vaults:"
    if (Test-Path $VaultsDir) {
        Get-ChildItem $VaultsDir -Filter "*.json" | ForEach-Object {
            $vault = $_.BaseName
            $content = Get-Content $_.FullName | ConvertFrom-Json
            if ($content.api_key) {
                Write-Host "  $vault (key: $($content.api_key.Substring(0, [Math]::Min(10, $content.api_key.Length)))...)"
            } else {
                Write-Host "  $vault (no key)"
            }
        }
    }
}

function Create-Vault {
    param([string]$Vault, [string]$Label = "opencode")
    if (-not $Vault) {
        Write-Host "Usage: Create-Vault <vault-name> [label]"
        return
    }
    $vaultFile = "$VaultsDir\$Vault.json"
    if (Test-Path $vaultFile) {
        Write-Host "Vault '$Vault' already exists"
        return
    }
    @{
        name = $Vault
        api_key = ""
        label = $Label
        created = (Get-Date -Format "o")
    } | ConvertTo-Json | Set-Content $vaultFile
    Write-Host "Vault '$Vault' created. Add API key with: Add-Key $Vault <key>"
}

function Add-Key {
    param([string]$Vault, [string]$Key)
    if (-not $Vault -or -not $Key) {
        Write-Host "Usage: Add-Key <vault-name> <api-key>"
        return
    }
    $vaultFile = "$VaultsDir\$Vault.json"
    if (-not (Test-Path $vaultFile)) {
        Write-Host "Vault '$Vault' does not exist"
        return
    }
    $content = Get-Content $vaultFile | ConvertFrom-Json
    $content.api_key = $Key
    $content | ConvertTo-Json | Set-Content $vaultFile
    Write-Host "API key added for vault '$Vault'"
}

function Remove-Vault {
    param([string]$Vault)
    if (-not $Vault) {
        Write-Host "Usage: Remove-Vault <vault-name>"
        return
    }
    $vaultFile = "$VaultsDir\$Vault.json"
    if (-not (Test-Path $vaultFile)) {
        Write-Host "Vault '$Vault' does not exist"
        return
    }
    Remove-Item $vaultFile
    Write-Host "Vault '$Vault' removed"
}

function Show-Vault {
    param([string]$Vault)
    if (-not $Vault) {
        Write-Host "Usage: Show-Vault <vault-name>"
        return
    }
    $vaultFile = "$VaultsDir\$Vault.json"
    if (-not (Test-Path $vaultFile)) {
        Write-Host "Vault '$Vault' not found"
        return
    }
    $content = Get-Content $vaultFile | ConvertFrom-Json
    $content.api_key = if ($content.api_key) { $content.api_key.Substring(0, [Math]::Min(20, $content.api_key.Length)) + "..." } else { "(none)" }
    $content | ConvertTo-Json
}

function Get-VaultForProject {
    param([string]$Project)
    $json = Get-Content $ConfigFile | ConvertFrom-Json
    if ($json.project_vaults.PSObject.Properties.Name -contains $Project) {
        $json.project_vaults.$Project
    } else {
        $json.default_vault
    }
}

function Get-AuthHeader {
    param([string]$Vault)
    $vaultFile = "$VaultsDir\$Vault.json"
    if (Test-Path $vaultFile) {
        $content = Get-Content $vaultFile | ConvertFrom-Json
        if ($content.api_key) {
            return "Authorization: Bearer $($content.api_key)"
        }
    }
    return ""
}

# Command dispatcher
$cmd = $args[0]
switch ($cmd) {
    "list" { List-Vaults }
    "create" { Create-Vault $args[1] $args[2] }
    "add-key" { Add-Key $args[1] $args[2] }
    "remove" { Remove-Vault $args[1] }
    "show" { Show-Vault $args[1] }
    "get-vault" { Get-VaultForProject $args[1] }
    "get-auth" { Get-AuthHeader $args[1] }
    default {
        Write-Host "Muninn Vault Manager (PowerShell)"
        Write-Host ""
        Write-Host "Usage: .\vaults.ps1 <command> [args]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  list                List all vaults"
        Write-Host "  create <v> [label]  Create vault"
        Write-Host "  add-key <v> <key>   Add API key"
        Write-Host "  remove <v>          Remove vault"
        Write-Host "  show <v>            Show vault details"
    }
}
