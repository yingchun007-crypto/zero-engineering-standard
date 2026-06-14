param(
    [string]$SkillName = "zero-engineering-standard",
    [string]$CodexHome = "$env:USERPROFILE\.codex",
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[zero-engineering-standard] $Message"
}

$source = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillFile = Join-Path $source "SKILL.md"
$referencesDir = Join-Path $source "references"

if (-not (Test-Path $skillFile)) {
    throw "SKILL.md not found. Please run this script from the skill repository root."
}

if (-not (Test-Path $referencesDir)) {
    throw "references directory not found. Please check the skill package is complete."
}

$skillsDir = Join-Path $CodexHome "skills"
$target = Join-Path $skillsDir $SkillName

Write-Step "Source: $source"
Write-Step "Target: $target"

New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

if (Test-Path $target) {
    if (-not $NoBackup) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backup = "$target.backup.$timestamp"
        Write-Step "Existing skill found. Moving it to: $backup"
        Move-Item -LiteralPath $target -Destination $backup
    }
    else {
        Write-Step "Existing skill found. Removing without backup."
        Remove-Item -LiteralPath $target -Recurse -Force
    }
}

Write-Step "Copying skill files..."
Copy-Item -LiteralPath $source -Destination $target -Recurse -Force

$installedSkillFile = Join-Path $target "SKILL.md"
$installedReferencesDir = Join-Path $target "references"

if (-not (Test-Path $installedSkillFile)) {
    throw "Install failed: SKILL.md was not copied."
}

if (-not (Test-Path $installedReferencesDir)) {
    throw "Install failed: references directory was not copied."
}

Write-Step "Installed successfully."
Write-Step "Restart Codex or open a new Codex thread to ensure the skill is discovered."

