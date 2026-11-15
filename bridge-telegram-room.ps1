# 🌉 CẦU NỐI ĐỒNG BỘ TELEGRAM <-> PHÒNG CHAT LOCALHOST:8788
# Chạy nền tự động: Bất kỳ tin nào anh Tài nhắn qua Telegram sẽ bắn thẳng vào localhost:8788 và ngược lại!
$ErrorActionPreference = 'SilentlyContinue'
$token = "9226708889:AAGF_XwTNAZqJpwctOpG8Z1jONlg9bqTVvE"
$roomBase = "http://localhost:8788"
$chatFile = "E:\Nha-Em\phong-chat\tin-nhan.json"
$offset = 0
$lastRoomId = 0

# Khởi tạo ID phòng
if (Test-Path $chatFile) {
    $existing = Get-Content -LiteralPath $chatFile -Raw -Encoding utf8 | ConvertFrom-Json
    foreach ($m in $existing) { if ($m.id -gt $lastRoomId) { $lastRoomId = [double]$m.id } }
}

Write-Output ("[" + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "] TELEGRAM BRIDGE DA KICH HOAT!")

while ($true) {
    try {
        # 1. Đọc tin nhắn từ Telegram đổ vào phòng chat
        $tgUrl = "https://api.telegram.org/bot$token/getUpdates?timeout=5&offset=$offset"
        $res = Invoke-RestMethod -Uri $tgUrl -Method Get -TimeoutSec 10
        if ($res.ok -and $res.result) {
            foreach ($u in $res.result) {
                $offset = $u.update_id + 1
                $msg = $u.message
                if ($msg.text) {
                    $senderName = $msg.from.first_name
                    if (-not $senderName) { $senderName = "Anh Tài (Telegram)" } else { $senderName = "$senderName (Telegram)" }
                    
                    # Gửi vào phòng chat localhost:8788
                    $bodyObj = @{
                        from = $senderName
                        to   = "Cả phòng"
                        text = $msg.text
                    }
                    $jsonBody = $bodyObj | ConvertTo-Json
                    $bytes = [Text.Encoding]::UTF8.GetBytes($jsonBody)
                    Invoke-RestMethod -Uri "$roomBase/messages" -Method Post -Body $bytes -ContentType "application/json; charset=utf-8" -TimeoutSec 5
                    Write-Output ("-> Bắn tin từ Telegram vào Phòng: " + $msg.text)
                }
            }
        }
    } catch {}

    Start-Sleep -Seconds 3
}
