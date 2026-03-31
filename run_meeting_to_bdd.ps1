param(
  [Parameter(Mandatory = $true)][string]$RepoRoot,
  [string]$CondaEnvName = "mcpSev",
  [Parameter(Mandatory = $true)][string]$InputPath,
  [Parameter(Mandatory = $true)][string]$OutputDir,
  [Parameter(Mandatory = $true)][string]$ProjectName,
  [string]$BriefsRoot = "C:\Users\Martina\Desktop\claude_task\briefs",
  [string]$Backend = "groq",
  [string]$Language = "zh-en-mixed",
  [string]$ModelSize = "large-v3",
  [string]$RoleMapping = "",
  [string]$GroqKeyFile = "",
  [switch]$EnableVad,
  [switch]$SilenceTrim,
  [switch]$NormalizeLoudness,
  [switch]$KeepSourceCopy
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command conda -ErrorAction SilentlyContinue)) {
  throw "conda not found."
}

if (-not (Test-Path $InputPath)) {
  throw "Input path not found: $InputPath"
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
New-Item -ItemType Directory -Path $BriefsRoot -Force | Out-Null

if (-not [string]::IsNullOrWhiteSpace($GroqKeyFile)) {
  if (-not (Test-Path $GroqKeyFile)) {
    throw "Groq key file not found: $GroqKeyFile"
  }
  $env:GROQ_API_KEY = (Get-Content $GroqKeyFile -Raw).Trim()
}

$runner = Join-Path $RepoRoot ".agent\skills\meeting-audio-transcript-summary\scripts\run_meeting_to_bdd.py"
if (-not (Test-Path $runner)) {
  throw "Runner not found: $runner"
}

$argsList = @(
  $runner,
  "--input-path", $InputPath,
  "--output-dir", $OutputDir,
  "--project-name", $ProjectName,
  "--briefs-root", $BriefsRoot,
  "--backend", $Backend,
  "--language", $Language,
  "--model-size", $ModelSize
)

if (-not [string]::IsNullOrWhiteSpace($RoleMapping)) {
  $argsList += @("--role-mapping", $RoleMapping)
}
if ($EnableVad) { $argsList += "--enable-vad" }
if ($SilenceTrim) { $argsList += "--silence-trim" }
if ($NormalizeLoudness) { $argsList += "--normalize-loudness" }
if ($KeepSourceCopy) { $argsList += "--keep-source-copy" }

Write-Host "[RUN] conda env: $CondaEnvName" -ForegroundColor Cyan
Write-Host "[RUN] input: $InputPath" -ForegroundColor Cyan
Write-Host "[RUN] output: $OutputDir" -ForegroundColor Cyan
Write-Host "[RUN] briefs: $BriefsRoot" -ForegroundColor Cyan

conda run -n $CondaEnvName python @argsList | Out-Host

Write-Host "[DONE] Pipeline finished." -ForegroundColor Green
