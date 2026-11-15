# Tao repo private + push (fix PATH cho gh tim thay git)
$ErrorActionPreference = 'Continue'
$gh  = "$env:ProgramFiles\GitHub CLI\gh.exe"
$env:Path = 'C:\Program Files\Git\cmd;' + $env:Path
Set-Location 'E:\Nha-Em\phong-chat'
Write-Output '== KIEM TRA GIT TU GH GOC NHIN =='
& git rev-parse --git-dir 2>&1 | Select-Object -First 1
Write-Output '== TAO REPO PRIVATE + PUSH =='
& $gh repo create ban-doan-phong-chat --private --source . --remote origin --push 2>&1 | Select-Object -First 6
Write-Output ('REPO EXIT: ' + $LASTEXITCODE)
Write-Output '== XAC MINH =='
& $gh repo view tranvantai2771998-cmd/ban-doan-phong-chat --json name,visibility,url 2>&1
