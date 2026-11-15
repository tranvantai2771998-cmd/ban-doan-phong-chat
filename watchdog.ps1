# WATCHDOG phong chat — canh /ping moi 30s, server chet tu dong hoi sinh (continuous-agent-loop)
$pwsh = 'C:\Users\DELL\AppData\Local\Microsoft\WindowsApps\pwsh.exe'
while ($true) {
    try {
        Invoke-RestMethod 'http://localhost:8788/ping' -TimeoutSec 4 | Out-Null
    } catch {
        Write-Output ((Get-Date -Format 'HH:mm:ss') + ' SERVER CHET — HOI SINH QUA TASK SCHEDULER...')
        # Hoi sinh qua schtasks: process do Task Scheduler so huu — KHONG console minimized (mau vat: minimized tu chet ~60s)
        & schtasks /Run /TN 'PhongChatServer' | Out-Null
        Start-Sleep 6
        try { Invoke-RestMethod 'http://localhost:8788/ping' -TimeoutSec 4 | Out-Null; Write-Output ((Get-Date -Format 'HH:mm:ss') + ' HOI SINH THANH CONG (via Task Scheduler)') } catch { Write-Output ((Get-Date -Format 'HH:mm:ss') + ' HOI SINH CHUA XONG — thu lan sau') }
    }
    Start-Sleep 30
}
