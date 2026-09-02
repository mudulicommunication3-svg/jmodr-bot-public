# ============================================================
#  push_update.ps1 - Encrypt local bot code and push to GitHub
#  (Run this AFTER editing jm1.8.0_3.py)
# ============================================================
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not (Test-Path 'STATE_KEY.local.txt')) {
    Write-Host "[ERROR] STATE_KEY.local.txt not found! Put your CODE_KEY in it first." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path 'jm1.8.0_3.py')) {
    Write-Host "[ERROR] jm1.8.0_3.py not found (the local source file)." -ForegroundColor Red
    exit 1
}

# 1. Encrypt
$env:CODE_KEY = (Get-Content 'STATE_KEY.local.txt' -Raw).Trim()
python botcrypt.py encrypt
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Encryption failed." -ForegroundColor Red; exit 1 }

# 2. Commit + push (only if bot.enc changed)
git add bot.enc
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "[INFO] No changes to push." -ForegroundColor Yellow
} else {
    git commit -m "update: encrypted bot source $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git push origin main
    Write-Host "[DONE] Encrypted code pushed to GitHub." -ForegroundColor Green
}