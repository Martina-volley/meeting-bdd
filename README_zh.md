# Meeting -> BDD 部署與使用（Claude Desktop / 其他電腦）

## 目標

這套部署檔可以在新電腦快速完成：

1. 建立 conda 執行環境（預設 `mcpSev`）
2. 安裝 meeting transcript skill 所需套件
3. （可選）把 `meeting-audio-transcript-summary` skill 複製到 Claude skills 目錄
4. 執行 preflight 環境檢查
5. 一鍵跑 meeting -> transcript -> raw-requirements

不包含 BDD skill 的安裝。

## 檔案說明

- `install_on_desktop.ps1`：新機安裝與初始化
- `preflight.ps1`：執行前環境檢查
- `run_meeting_to_bdd.ps1`：正式執行入口
- `export_skill_bundle.ps1`：打包給其他人/其他電腦

## 一次部署（建議順序）

```powershell
powershell -ExecutionPolicy Bypass -File .\runtime\meeting-bdd\install_on_desktop.ps1 `
  -RepoRoot "C:\Users\Martina\Desktop\ADAT\code" `
  -CondaEnvName "mcpSev" `
  -CreateEnv `
  -InstallSkill `
  -ClaudeSkillsDir "$HOME\.agent\skills"
```

## 先做 preflight

```powershell
powershell -ExecutionPolicy Bypass -File .\runtime\meeting-bdd\preflight.ps1 `
  -RepoRoot "C:\Users\Martina\Desktop\ADAT\code" `
  -CondaEnvName "mcpSev" `
  -InputPath "C:\Users\Martina\Desktop\claude_task\recording\example.mp4" `
  -OutputDir "C:\Users\Martina\Desktop\claude_task\briefs\tmp-meeting-output" `
  -GroqKeyFile "C:\Users\Martina\Desktop\claude_task\recording\groq_testkey_30days.txt"
```

## 正式執行

```powershell
powershell -ExecutionPolicy Bypass -File .\runtime\meeting-bdd\run_meeting_to_bdd.ps1 `
  -RepoRoot "C:\Users\Martina\Desktop\ADAT\code" `
  -CondaEnvName "mcpSev" `
  -InputPath "C:\Users\Martina\Desktop\claude_task\recording\meeting.mp4" `
  -OutputDir "C:\Users\Martina\Desktop\claude_task\briefs\tmp-meeting-output" `
  -ProjectName "my-project" `
  -BriefsRoot "C:\Users\Martina\Desktop\claude_task\briefs" `
  -Backend "groq" `
  -Language "zh-en-mixed" `
  -GroqKeyFile "C:\Users\Martina\Desktop\claude_task\recording\groq_testkey_30days.txt" `
  -EnableVad -SilenceTrim -NormalizeLoudness
```

## 輸出位置

- 逐字稿輸出：
  - `<OutputDir>\transcript_raw.json`
  - `<OutputDir>\transcript_raw.md`
  - `<OutputDir>\transcript_clean.md`
- BDD 接手輸出：
  - `<BriefsRoot>\YYYY-MM\<ProjectName>\raw-requirements.md`
  - `<BriefsRoot>\YYYY-MM\<ProjectName>\bdd_input_manifest.json`

## 打包給其他人

```powershell
powershell -ExecutionPolicy Bypass -File .\runtime\meeting-bdd\export_skill_bundle.ps1 `
  -RepoRoot "C:\Users\Martina\Desktop\ADAT\code" `
  -OutDir "C:\Users\Martina\Desktop\claude_task\share"
```

會生成 zip，內含：
- meeting skill
- workflows 文件
- runtime 部署腳本
