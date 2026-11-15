# Trien khai GitHub repo private cho phong chat (Bo Gia)
$ErrorActionPreference = 'Stop'
$git = 'C:\Program Files\Git\cmd\git.exe'
$gh  = "$env:ProgramFiles\GitHub CLI\gh.exe"
Set-Location 'E:\Nha-Em\phong-chat'

Write-Output '== 1. INIT + CONFIG (danh tinh team, khong mo danh ai) =='
& $git init 2>&1 | Select-Object -First 1
& $git config user.name 'Bo Gia (ZCode) - Team Bang Doan'
& $git config user.email 'bogia@ban-doan.local'

Write-Output '== 2. ADD + COMMIT =='
& $git add -A
& $git commit -m 'Phong chung Bang Doan v3: chat server cho nguoi + AI agents (mutex, atomic write, archive, /members, /ping)' 2>&1 | Select-Object -First 2
Write-Output ('COMMIT EXIT: ' + $LASTEXITCODE)

Write-Output '== 3. TAO REPO PRIVATE + PUSH =='
& $gh repo create ban-doan-phong-chat --private --source . --remote origin --push 2>&1 | Select-Object -First 5
Write-Output ('REPO EXIT: ' + $LASTEXITCODE)

Write-Output '== 4. XAC MINH =='
& $gh repo view tranvantai2771998-cmd/ban-doan-phong-chat --json name,visibility,url 2>&1
