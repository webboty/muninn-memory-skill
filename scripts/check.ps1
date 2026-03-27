# MuninnDB Check Script - PowerShell version
# Checks if MuninnDB is installed and running

$MuninPath = $null
$Running = $false

# Check if muninn is in PATH
$MuninPath = Get-Command muninn -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

# Check common install locations
if (-not $MuninPath) {
    $LocalAppData = [Environment]::GetFolderPath("LocalApplicationData")
    $Paths = @(
        "$LocalAppData\muninn\bin\muninn.exe",
        "$env:LOCALAPPDATA\muninn\bin\muninn.exe",
        "C:\Program Files\muninn\muninn.exe"
    )
    foreach ($p in $Paths) {
        if (Test-Path $p) {
            $MuninPath = $p
            break
        }
    }
}

# Check if running on port 8475
try {
    $Response = Invoke-WebRequest -Uri "http://localhost:8475/api/stats" -UseBasicParsing -ErrorAction SilentlyContinue
    if ($Response.StatusCode -eq 200) {
        $Running = $true
    }
} catch {
    $Running = $false
}

# Output status
if ($MuninPath) {
    Write-Host "INSTALLED: $MuninPath"
} else {
    Write-Host "INSTALLED: false"
}

if ($Running) {
    Write-Host "RUNNING: true"
} else {
    Write-Host "RUNNING: false"
}
