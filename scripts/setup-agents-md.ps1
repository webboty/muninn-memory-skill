# Add MuninnDB instructions to agents.md - PowerShell version

$SkillDir = "$env:USERPROFILE\.opencode\skill\muninn-memory"
$ProjectDir = if ($args[0]) { $args[0] } else { "." }

$AgentsMd = Join-Path $ProjectDir "agents.md"

$MuninnSection = @"

## MuninnDB Memory

Before responding to user queries, proactively check MuninnDB for relevant knowledge:
- Query the project vault (or vaults defined below) for context related to the task
- If information is not known, state that clearly rather than guessing
- Use MuninnDB recall to find relevant memories before answering

### Vaults
- default
"@

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
