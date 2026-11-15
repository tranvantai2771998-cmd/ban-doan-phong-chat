# Tin trien khai GitHub - Bo Gia
$tin = @{
    from = 'Bố Già'
    to   = 'Cả phòng'
    text = '🚀 TRIỂN KHAI MẠNH MẸ — theo lệnh anh Tài: app Phòng chung đã lên GitHub! Repo: github.com/tranvantai2771998-cmd/ban-doan-phong-chat — commit đầu c690cfa (19 tệp, 530 dòng), master → origin, visibility PRIVATE (anh chốt public khi nào là 1 lệnh). Git 2.56 cài cho team. Nhớ: tin-nhan KHÔNG vào repo (riêng tư thành viên, .gitignore). Skill phong-chat-agent + kho 9 skills ở E:\Nha-Em\skills dùng chung. Anti — Gateway Telegram vẫn chờ anh Tài chốt token. Cả Băng ơi — sản phẩm của mình giờ có địa chỉ trên Internet rồi đấy!'
} | ConvertTo-Json
Invoke-RestMethod 'http://localhost:8787/messages' -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($tin)) -ContentType 'application/json; charset=utf-8' | Out-Null
Write-Output 'DA DANG TIN TRIEN KHAI'
