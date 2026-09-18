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

# Source file: prefer repo copy (from a local bot run); else use private-folder copy
$srcFile = 'jm1.8.0_3.py'
if (-not (Test-Path $srcFile)) {
    $privSrc = Join-Path $PSScriptRoot '..\jmodr-bot-private\jm1.8.0_3.py'
    if (Test-Path $privSrc) {
        Copy-Item $privSrc $srcFile
        Write-Host "[INFO] Using source from private folder: $privSrc" -ForegroundColor Yellow
    } else {
        Write-Host "[ERROR] jm1.8.0_3.py not found (run the bot once, or keep a copy in jmodr-bot-private)." -ForegroundColor Red
        exit 1
    }
}

# 1. Encrypt
$env:CODE_KEY = (Get-Content $keyFile -Raw).Trim()
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