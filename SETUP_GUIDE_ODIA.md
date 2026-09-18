# 🚀 JioMart Bot → GitHub Setup Guide (ଓଡ଼ିଆ)

ଏହା ଆରମ୍ଭରୁ (startup) ଠାରୁ bot ଚଲାଇବାର ସମ୍ପୂର୍ଣ୍ଣ ଗାଇଡ୍।

---

## 📋 ପାଦ 0 — କ'ଣ କ'ଣ ଦରକାର? (ଏକଥର ମାତ୍ର)

| ଜିନିଷ | ସ୍ଥିତି (ଆପଣଙ୍କ PC) |
|---|---|
| Python 3.11+ | ✅ ଅଛି |
| git | ✅ ଅଛି (2.55.0) |
| GitHub CLI (gh) | ✅ ଅଛି (2.98.0 — ମୁଁ install କରିସାରିଲି) |
| GitHub ଆକାଉଣ୍ଟ | ନଥିଲେ ତିଆରି କରନ୍ତୁ → https://github.com/signup |
| Telegram Bot Token | ✅ `.env` ଫାଇଲ୍ ରେ ଅଛି (BOT_TOKEN=...) |

---

## 📋 ପାଦ 1 — GitHub କୁ ଲଗିନ୍ (ଏକଥର ମାତ୍ର)

ନୂଆ **PowerShell** ଖୋଲନ୍ତୁ (Win key → "powershell" ଟାଇପ୍ → Enter):

```powershell
gh auth login
```

ପଚରିଲେ ଏମିତି ଉତ୍ତର ଦିଅନ୍ତୁ:
1. `Where do you use GitHub?` → **GitHub.com** → Enter
2. `Preferred protocol?` → **HTTPS** → Enter
3. `Authenticate Git with your GitHub credentials?` → **Yes** → Enter
4. `How to authenticate?` → **Login with a web browser** → Enter
5. ସ୍କ୍ରିନ୍ ରେ ଏକ code ଦେଖିବ (ଯେପରି `ABCD-1234`) → **Enter ଦବାନ୍ତୁ**
6. Browser ଖୋଲିବ → code paste କରନ୍ତୁ → **Authorize github** ଦବାନ୍ତୁ

✅ ସଫଳ ହେଲେ ଦେଖିବ: `✓ Logged in as ଆପଣଙ୍କ-ନାମ`

---

## 📋 ପାଦ 2 — ବାଛନ୍ତୁ: Private କି Public?

| | Private | Public (ପରାମର୍ଶ) |
|---|---|---|
| ମାଗଣା ସମୟ | 2000 ମିନିଟ୍/ମାସ (~5 ଥର) | ♾️ 24×7 ଚାଲୁ |
| କୋଡ୍ କେଉଁଠି | କେବଳ ଆପଣ ଦେଖିବେ | ⚠️ ସବୁ ଲୋକେ ଦେଖିପାରିବେ |
| Sessions ନିରାପତ୍ତା | cache ରେ | 🔐 encrypted ରେ |

---

## 📋 ପାଦ 3 — Setup Script ଚଲାନ୍ତୁ (ଏକ କମାଣ୍ଡ୍!)

### Public ପାଇଁ (24×7 ମାଗଣା):
```powershell
cd d:\jmodr
powershell -ExecutionPolicy Bypass -File setup_github_public.ps1
```

### Private ପାଇଁ:
```powershell
cd d:\jmodr
powershell -ExecutionPolicy Bypass -File setup_github.ps1
```

Script ସ୍ୱୟଂଚାଳିତ ଭାବେ କରିବ:
- git init + commit
- GitHub repo ତିଆରି (`jmodr-bot-public` ବା `jmodr-bot`) + push
- BOT_TOKEN (ଓ STATE_KEY) secret ସେଭ୍
- Bot START! → ଶେଷରେ **live log ଲିଙ୍କ୍** ଦେଖାଇବ

> 🔑 **IMPORTANT (public):** ଶେଷରେ `STATE_KEY.local.txt` ତିଆରି ହେବ — ଏହାକୁ
> USB/ଅନ୍ୟ ଜାଗାରେ backup କରନ୍ତୁ! ହଜିଲେ ସବୁ ଲଗିନ୍ ନଷ୍ଟ।

---

## 📋 ପାଦ 4 — ପ୍ରଥମ ଲଗିନ୍ (Telegram ରେ, ଏକଥର ମାତ୍ର)

GitHub ର bot ଚାଲିଗଲା ପରେ:
1. Telegram ଖୋଲନ୍ତୁ → ଆପଣଙ୍କ bot କୁ **`/start`** ପଠାନ୍ତୁ
2. **🔑 Switch Session** → **➕ New Login** ଦବାନ୍ତୁ
3. ଫୋନ୍ ନମ୍ବର ପଠାନ୍ତୁ → OTP ପଠାନ୍ତୁ (ଯାହା JioMart ଆପଣଙ୍କ SMS ରେ ଦେଇଥିବ)
4. ✅ ଲଗିନ୍ ସେଭ୍ ହୋଇ encrypted ହୋଇ cache ରେ ରହିଗଲା

ଏବେ ପ୍ରତି restart ରେ ଆଉ ଲଗିନ୍ ଦରକାର ନାହିଁ!

---

## 📋 ପାଦ 5 — ଦେଖିବା / ବନ୍ଦ କରିବା / ପୁଣି ଚଲାଇବା

### ଚାଲୁଛି କି ଦେଖନ୍ତୁ:
- Browser ରେ: `https://github.com/ଆପଣଙ୍କ-ନାମ/jmodr-bot-public/actions`
- 🟢 ସବୁଜ dot = ଚାଲୁ | 🔴 ନାଲି = fail (log ପଢ଼ନ୍ତୁ)

### ବନ୍ଦ କରନ୍ତୁ:
```powershell
gh workflow disable bot_public.yml --repo jmodr-bot-public
```
(ପୁଣି ଚଲାଇବା ପାଇଁ: `enable` କରନ୍ତୁ + Actions ଟାବ୍ → Run workflow)

### ନିଜେ restart:
Actions ଟାବ୍ → JioMart Bot → **Run workflow** → Run

### PC ମଧ୍ୟ ଚଲାଇବାକୁ ଚାହାଁନ୍ତି:
```powershell
cd d:\jmodr
python jm1.8.0_3.py
```
⚠️ ଦୁଇଟି ଏକାଠି ଚଲାନ୍ତୁ ନାହିଁ — Telegram ର conflict ହେବ।

---

## 🔧 ସାଧାରଣ ସମସ୍ୟା ଓ ସମାଧାନ

| ସମସ୍ୟା | ସମାଧାନ |
|---|---|
| `gh: command not found` | ନୂଆ terminal ଖୋଲନ୍ତୁ (PATH refresh) |
| `BOT_TOKEN not found in .env` | `.env` ରେ `BOT_TOKEN=123456:ABC...` ଅଛି କି ଦେଖନ୍ତୁ |
| Actions ଚାଲୁ ହେଉନାହିଁ | repo Settings → Actions → Allow all actions |
| Cron delay | GitHub 5-15 ମିନିଟ୍ ଦେରି କରିପାରେ — ସ୍ୱାଭାବିକ |
| 60 ଦିନ ପରେ ବନ୍ଦ | ବେଳେବେଳେ ଛୋଟ commit push କରନ୍ତୁ |
| Session ହଜିଗଲା | STATE_KEY ବଦଳିଛି କି? ପୁରୁଣା key ରେ secret ସେଟ୍ କରନ୍ତୁ |

---

## 💬 ଚାଳନା ସାରାଂଶ

- Bot ନିଜେ ପ୍ରତି 6 ଘଣ୍ଟାରେ restart ହୁଏ — କିଛି କରିବା ଦରକାର ନାହିଁ
- PC ବନ୍ଦ ଥିଲେ ମଧ୍ୟ bot GitHub ରେ ଚାଲୁଥିବ
- କୌଣସି ସମସ୍ୟା ହେଲେ → Actions log ରୁ error copy କରି Cline କୁ ପଠାନ୍ତୁ
