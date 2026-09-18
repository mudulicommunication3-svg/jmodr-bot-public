# ============================================================
#  push_update.ps1 - Encrypt local bot code and push to GitHub
#  (Run this AFTER editing jm1.8.0_3.py)
# ============================================================
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$keyFile = 'private_keys\CODE_KEY.txt'
if (-not (Test-Path $keyFile)) {
    $keyFile = Join-Path $PSScriptRoot '..\jmodr-bot-private\private_keys\CODE_KEY.txt'
}
if (-not (Test-Path $keyFile)) {
    Write-Host "[ERROR] CODE_KEY.txt not found (looked in private_keys\ and ..\jmodr-bot-private\private_keys\)" -ForegroundColor Red
    exit 1
}

# Source file: always the PRIVATE copy (plaintext is never kept in the public folder)
$srcFile = Join-Path $PSScriptRoot '..\jmodr-bot-private\jm1.8.0_3.py'
if (-not (Test-Path $srcFile)) {
    Write-Host "[ERROR] Source not found: $srcFile (the plaintext bot lives in the private folder)" -ForegroundColor Red
    exit 1
}

# 1. Encrypt (private source -> bot.enc in this public repo)
$env:CODE_KEY = (Get-Content $keyFile -Raw).Trim()
python botcrypt.py encrypt $srcFile 'bot.enc'
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Encryption failed." -ForegroundColor Red; exit 1 }

# 2. Commit + push (only if bot.enc changed)
git add bot.enc
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "[INFO] No changes to push." -ForegroundColor Yellow
} else {
    git commit -m "update: encrypted bot source $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    # the cloud bot pushes its own backups - sync first so the push is never rejected
    git pull --rebase --autostash origin main > $null 2>&1
    git rebase --abort > $null 2>&1
    git push origin main
    Write-Host "[DONE] Encrypted code pushed to GitHub." -ForegroundColor Green
}