param(
  [Parameter(Mandatory = $true)][string]$RepoRoot,
  [string]$CondaEnvName = "mcpSev",
  [string]$PythonVersion = "3.10",
  [switch]$CreateEnv,
  [switch]$InstallSkill,
  [string]$ClaudeSkillsDir = ""
)

$ErrorActionPreference = "Stop"

function Assert-Command([string]$cmd) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    throw "Command not found: $cmd"
  }
}

Write-Host "[1/5] Checking conda..." -ForegroundColor Cyan
Assert-Command "conda"

$reqPath = Join-Path $RepoRoot ".agent\skills\meeting-audio-transcript-summary\scripts\requirements.txt"
if (-not (Test-Path $reqPath)) {
  throw "requirements.txt not found: $reqPath"
}

if ($CreateEnv) {
  Write-Host "[2/5] Creating conda env: $CondaEnvName (python=$PythonVersion)" -ForegroundColor Cyan
  conda create -n $CondaEnvName "python=$PythonVersion" -y | Out-Host
}

Write-Host "[3/5] Installing python dependencies..." -ForegroundColor Cyan
conda run -n $CondaEnvName python -m pip install -r $reqPath | Out-Host

Write-Host "[4/5] Checking ffmpeg..." -ForegroundColor Cyan
if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
  ffmpeg -version | Select-Object -First 1 | Out-Host
}
else {
  Write-Warning "ffmpeg not found in PATH. Please install ffmpeg before running ASR pipeline."
}

if ($InstallSkill) {
  if ([string]::IsNullOrWhiteSpace($ClaudeSkillsDir)) {
    throw "InstallSkill specified but ClaudeSkillsDir is empty."
  }
  $src = Join-Path $RepoRoot ".agent\skills\meeting-audio-transcript-summary"
  $dst = Join-Path $ClaudeSkillsDir "meeting-audio-transcript-summary"
  Write-Host "[5/5] Copying skill to Claude skills dir..." -ForegroundColor Cyan
  New-Item -ItemType Directory -Force -Path $ClaudeSkillsDir | Out-Null
  Copy-Item -Path $src -Destination $dst -Recurse -Force
  Write-Host "[OK] Skill copied: $dst" -ForegroundColor Green
}
else {
  Write-Host "[5/5] Skill copy skipped." -ForegroundColor Yellow
}

Write-Host "[DONE] Desktop install completed." -ForegroundColor Green
