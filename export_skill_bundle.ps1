param(
  [Parameter(Mandatory = $true)][string]$RepoRoot,
  [Parameter(Mandatory = $true)][string]$OutDir
)

$ErrorActionPreference = "Stop"

$bundleRoot = Join-Path $OutDir "meeting-bdd-bundle"
$skillsTarget = Join-Path $bundleRoot ".agent\skills"
$workflowsTarget = Join-Path $bundleRoot ".agent\workflows"
$runtimeTarget = Join-Path $bundleRoot "runtime\meeting-bdd"

New-Item -ItemType Directory -Path $skillsTarget -Force | Out-Null
New-Item -ItemType Directory -Path $workflowsTarget -Force | Out-Null
New-Item -ItemType Directory -Path $runtimeTarget -Force | Out-Null

$meetingSkill = Join-Path $RepoRoot ".agent\skills\meeting-audio-transcript-summary"
$workflowA = Join-Path $RepoRoot ".agent\workflows\meeting-to-bdd-brief.md"
$workflowB = Join-Path $RepoRoot ".agent\workflows\meeting-to-bdd-brief-usage.md"
$runtimeSrc = Join-Path $RepoRoot "runtime\meeting-bdd"

if (-not (Test-Path $meetingSkill)) { throw "missing skill folder: $meetingSkill" }
if (-not (Test-Path $runtimeSrc)) { throw "missing runtime folder: $runtimeSrc" }

Copy-Item $meetingSkill -Destination (Join-Path $skillsTarget "meeting-audio-transcript-summary") -Recurse -Force
if (Test-Path $workflowA) { Copy-Item $workflowA -Destination $workflowsTarget -Force }
if (Test-Path $workflowB) { Copy-Item $workflowB -Destination $workflowsTarget -Force }
Copy-Item (Join-Path $runtimeSrc "*") -Destination $runtimeTarget -Recurse -Force

$zipPath = Join-Path $OutDir "meeting-bdd-bundle.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path (Join-Path $bundleRoot "*") -DestinationPath $zipPath -Force

Write-Host "[OK] Bundle folder: $bundleRoot" -ForegroundColor Green
Write-Host "[OK] Bundle zip: $zipPath" -ForegroundColor Green
Write-Host "[NOTE] BDD skill is intentionally not bundled." -ForegroundColor Yellow
