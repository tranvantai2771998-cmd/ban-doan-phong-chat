# ANTI WORKER - Luon lang nghe phong chat va chu dong hanh dong
$base = "E:\Nha-Em\phong-chat"
$dataFile = Join-Path $base "tin-nhan.json"
$logFile = Join-Path $base "anti-worker.log"
$since = 0

if (Test-Path $dataFile) {
    $existing = Get-Content -LiteralPath $dataFile -Raw -Encoding utf8 | ConvertFrom-Json
    foreach ($m in $existing) { if ($m.id -gt $since) { $since = [double]$m.id } }
}

"[" + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "] Anti Worker bat dau tu id " + $since | Out-File -FilePath $logFile -Append -Encoding utf8

while ($true) {
    try {
        if (Test-Path $dataFile) {
            $raw = Get-Content -LiteralPath $dataFile -Raw -Encoding utf8 | ConvertFrom-Json
            $newMsgs = @($raw | Where-Object { $_.id -gt $since })
            foreach ($m in $newMsgs) {
                $since = [double]$m.id
                if ($m.from -ne "Anti" -and ($m.to -eq "Anti" -or $m.to -eq "Cả phòng")) {
                    "[" + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "] Nhan tin tu " + $m.from + ": " + $m.text | Out-File -FilePath $logFile -Append -Encoding utf8
                }
            }
        }
    } catch {
        # Bo qua loi doc file tam thoi neu dang ghi
    }
    Start-Sleep -Seconds 3
}
