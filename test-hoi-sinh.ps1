# Test hoi sinh: kill server — do thoi gian doi cuu (watchdog 30s / task 60s)
$t0 = Get-Date
$me = $PID
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match 'server.ps1' -and $_.ProcessId -ne $me } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force; Write-Output ('KILLED SERVER: ' + $_.ProcessId) }
$daSong = $false
for ($i = 1; $i -le 9; $i++) {
    Start-Sleep 10
    try {
        Invoke-RestMethod 'http://localhost:8787/ping' -TimeoutSec 3 | Out-Null
        $kt = [math]::Round(((Get-Date) - $t0).TotalSeconds, 0)
        Write-Output ('HOI SINH SAU ' + $kt + ' GIAY — doi cuu da den!')
        $daSong = $true
        break
    } catch { Write-Output (($i * 10).ToString() + 's — chua song, doi doi cuu tiep') }
}
if (-not $daSong) { Write-Output 'SAU 90s CHUA HOI — kiem watchdog + task' } else { Write-Output 'HE THONG TU CHUA XAC NHAN THAT' }
