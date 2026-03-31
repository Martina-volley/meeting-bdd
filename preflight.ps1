param(
  [Parameter(Mandatory = $true)][string]$RepoRoot,
  [string]$CondaEnvName = "mcpSev",
  [string]$InputPath = "",
  [string]$OutputDir = "",
  [string]$GroqKeyFile = ""
)

$ErrorActionPreference = "Stop"

function Test-Step([string]$name, [ScriptBlock]$block) {
  try {
    & $block
    Write-Host "[PASS] $name" -ForegroundColor Green
  }
  catch {
    Write-Host "[FAIL] $name :: $($_.Exception.Message)" -ForegroundColor Red
  }
}

Write-Host "=== Meeting->BDD Preflight ===" -ForegroundColor Cyan

Test-Step "conda exists" {
  if (-not (Get-Command conda -ErrorAction SilentlyContinue)) { throw "conda not found" }
}

Test-Step "python in env" {
  conda run -n $CondaEnvName python --version | Out-Host
}

Test-Step "ffmpeg exists" {
  if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) { throw "ffmpeg not found in PATH" }
}

Test-Step "runner script exists" {
  $runner = Join-Path $RepoRoot ".agent\skills\meeting-audio-transcript-summary\scripts\run_meeting_to_bdd.py"
  if (-not (Test-Path $runner)) { throw "missing runner: $runner" }
}

if (-not [string]::IsNullOrWhiteSpace($InputPath)) {
  Test-Step "input path exists" {
    if (-not (Test-Path $InputPath)) { throw "input path missing: $InputPath" }
  }
}

if (-not [string]::IsNullOrWhiteSpace($OutputDir)) {
  Test-Step "output dir writable" {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    $probe = Join-Path $OutputDir ".write_probe.txt"
    "ok" | Set-Content -Path $probe -Encoding UTF8
    Remove-Item $probe -Force
  }
}

if (-not [string]::IsNullOrWhiteSpace($GroqKeyFile)) {
  Test-Step "groq key file readable" {
    if (-not (Test-Path $GroqKeyFile)) { throw "key file missing: $GroqKeyFile" }
    $key = (Get-Content $GroqKeyFile -Raw).Trim()
    if ($key.Length -lt 20) { throw "key content too short" }
  }
}

Write-Host "=== Preflight done ===" -ForegroundColor Cyan
