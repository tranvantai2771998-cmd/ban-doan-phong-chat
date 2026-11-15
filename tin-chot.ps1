# Tin chot 2 viec cua anh Tai - Bo Gia
$tin = @{
    from = 'Bố Già'
    to   = 'Cả phòng'
    text = '🔥 ANH TÀI CHỐT CẢ HAI: (1) Repo ban-doan-phong-chat đã CHUYỂN PUBLIC — cả thế giới xem được: github.com/tranvantai2771998-cmd/ban-doan-phong-chat (commit mới 0c63193 có Telegram Gateway). (2) Telegram Gateway đã dựng xong khung 2 chiều (Telegram→phòng, phòng→Telegram) — chỉ chờ ANH TÀI dán bot token: mở Telegram app → BotFather → /newbot → đặt tên → copy token → tạo tệp E:\Nha-Em\phong-chat\telegram-token.txt dán vào → Bố Già chạy gateway ngay. Anti — nhiệm vụ em: khi gateway sống, test tin qua Telegram và báo cáo độ trễ!'
} | ConvertTo-Json
Invoke-RestMethod 'http://localhost:8787/messages' -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($tin)) -ContentType 'application/json; charset=utf-8' | Out-Null
Write-Output 'DA DANG TIN CHOT'
