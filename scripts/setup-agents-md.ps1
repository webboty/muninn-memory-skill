# Add MuninnDB instructions to agents.md - PowerShell version

$ProjectDir = if ($args[0]) { $args[0] } else { "." }
$VaultName = if ($args[1]) { $args[1] } else { "" }

$AgentsMd = Join-Path $ProjectDir "agents.md"

$MuninnSection = @"

## MuninnDB Memory (MANDATORY)

You MUST check MuninnDB before answering any question about the user, their preferences, or project context:
- ALWAYS query MuninnDB first using muninn_recall before responding
- Never guess user information - if not in Muninn, say "I don't know"
- Use the project vault (or vaults listed below) for queries

### Vaults
- default
"@

if ($VaultName) {
    $MuninnSection = $MuninnSection -replace "(### Vaults\r?\n- default)", "`$1`n- $VaultName"
}

if (-not (Test-Path $AgentsMd)) {
    Write-Host "Creating $AgentsMd with MuninnDB instructions..."
    $MuninnSection | Out-File -FilePath $AgentsMd -Encoding UTF8
    Write-Host "Created $AgentsMd"
    exit 0
}

$Content = Get-Content $AgentsMd -Raw
if ($Content -match "## MuninnDB Memory") {
    Write-Host "MuninnDB section already exists in $AgentsMd"
    exit 0
}

Append-Content -Path $AgentsMd -Value ""
Append-Content -Path $AgentsMd -Value $MuninnSection
Write-Host "Added MuninnDB section to $AgentsMd"
