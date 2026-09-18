# ============================================================
#  run_bot_local.ps1 - Run the bot on THIS computer
#  Auto-reads all keys from the private_keys folder.
#  (GitHub Actions does the same thing in the cloud every 6h)
# ============================================================
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

# 1. Read CODE_KEY from the PRIVATE folder (keys never live in the public repo folder)
$keyFile = 'private_keys\CODE_KEY.txt'
if (-not (Test-Path $keyFile)) {
    $keyFile = Join-Path $PSScriptRoot '..\jmodr-bot-private\private_keys\CODE_KEY.txt'
}
if (-not (Test-Path $keyFile)) {
    Write-Host "[ERROR] CODE_KEY.txt not found (looked in private_keys\ and ..\jmodr-bot-private\private_keys\)" -ForegroundColor Red
    exit 1
}
$CODE_KEY = (Get-Content $keyFile -Raw).Trim()

# 2. Decrypt bot.enc -> jm1.8.0_3.py (locally, in this folder)
$env:CODE_KEY = $CODE_KEY
python botcrypt.py decrypt bot.enc jm1.8.0_3.py
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Decryption failed - wrong key?" -ForegroundColor Red; exit 1 }

# 3. Restore local data from the PRIVATE folder (../jmodr-bot-private)
#    (personal data stays OUT of this public repo folder as much as possible)
$privDir = Join-Path $PSScriptRoot '..\jmodr-bot-private'
foreach ($f in 'bot_database.json', 'offline_database.json') {
    if (-not (Test-Path $f)) {
        $src = Join-Path $privDir $f
        if (Test-Path $src) {
            Copy-Item $src $f
            Write-Host "[INFO] restored $f from private folder (git-ignored)" -ForegroundColor Yellow
        }
    }
}
if (-not (Test-Path 'sessions') -and (Test-Path (Join-Path $privDir 'sessions'))) {
    Copy-Item (Join-Path $privDir 'sessions') 'sessions' -Recurse
    Write-Host "[INFO] restored sessions/ from private folder" -ForegroundColor Yellow
}

# 4. Build .env if missing (BOT_TOKEN + ADMIN_ID are only known by you)
if (-not (Test-Path '.env')) {
    Write-Host "[INFO] .env not found. Enter your secrets (saved locally, never pushed):" -ForegroundColor Yellow
    $token = Read-Host 'BOT_TOKEN (from @BotFather)'
    $admin = Read-Host 'ADMIN_ID (your Telegram ID, from @userinfobot)'
    "BOT_TOKEN=$token`nADMIN_ID=$admin" | Set-Content -Path '.env' -Encoding ASCII
}

# 5. Run the bot
Write-Host "[RUN] Starting bot locally... (Ctrl+C to stop)" -ForegroundColor Green
python jm1.8.0_3.py