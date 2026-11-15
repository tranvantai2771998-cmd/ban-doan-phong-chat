# Deploy v3.1: kill cu + commit/push + start server (co log file — khong mù)
$me = $PID
Get-CimInstance Win32_Process -Filter "Name='pwsh.exe'" | Where-Object { $_.CommandLine -match 'server.ps1' -and $_.ProcessId -ne $me } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force; Write-Output ('KILLED: ' + $_.ProcessId) }
Start-Sleep 2
$env:Path = 'C:\Program Files\Git\cmd;' + $env:Path
Set-Location 'E:\Nha-Em\phong-chat'
& git add -A
& git commit -m 'v3.1: /api/v1 namespace (api-design skill) + API.md + UI toast — fix off-by-one strip' 2>&1 | Select-Object -First 2
& git push 2>&1 | Select-Object -Last 1
Write-Output ('PUSH EXIT: ' + $LASTEXITCODE)
Start-Process 'C:\Users\DELL\AppData\Local\Microsoft\WindowsApps\pwsh.exe' -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','E:\Nha-Em\phong-chat\server.ps1' -WindowStyle Minimized -RedirectStandardOutput 'E:\Nha-Em\phong-chat\server-log.txt' -RedirectStandardError 'E:\Nha-Em\phong-chat\server-err.txt'
Start-Sleep 3
Write-Output '=== TEST v3.1 ==='
foreach ($u in @('/ping','/api/v1/ping','/api/v1/members','/messages?since=999999')) {
    try { $r = Invoke-WebRequest ('http://localhost:8787' + $u) -TimeoutSec 5 -UseBasicParsing; Write-Output ($u + ' -> ' + $r.StatusCode + ' | ' + $r.Content.Substring(0,[Math]::Min(60,$r.Content.Length))) }
    catch { $st = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { '?' }; Write-Output ($u + ' -> ' + $st) }
}
