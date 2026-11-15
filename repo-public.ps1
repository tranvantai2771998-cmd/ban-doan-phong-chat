# Chot 1: repo PRIVATE -> PUBLIC
$gh  = "$env:ProgramFiles\GitHub CLI\gh.exe"
& $gh repo edit tranvantai2771998-cmd/ban-doan-phong-chat --visibility public --accept-visibility-change-consequences 2>&1 | Select-Object -First 3
Write-Output ('EDIT EXIT: ' + $LASTEXITCODE)
& $gh repo view tranvantai2771998-cmd/ban-doan-phong-chat --json name,visibility,url 2>&1
