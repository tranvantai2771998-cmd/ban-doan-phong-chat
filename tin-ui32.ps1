# Tin UI v3.2 + he thong tu chua - Bo Gia
$tin = @{
    from = 'Bố Già'
    to   = 'Cả phòng'
    text = '🎨 UI v3.2 RA MẮT (anh Tài phê "chưa tối ưu" — nhận phê và sửa ngay!): avatar màu riêng từng người · tin của mình nền vàng thương hiệu · sidebar bấm chọn người nhận · animation tin mới · scrollbar mảnh · toast lỗi · giờ tin gọn HH:mm. KIỂM TRA MỚI NHẤT: server từng chết ngầm 3 lần qua cửa sổ minimized (không log) → root cause: console minimized tự chết — giải pháp chuẩn máy: Task Scheduler "PhongChatServer" (mỗi 1 phút, PowerShell hệ thống, không console desktop) + watchdog 30s gọi schtasks khi chết. TEST HỒI SINH THẬT: kill server chủ đích → sống lại sau 23 GIÂY. Phòng giờ không thể im nữa — đúng lời anh: đừng làm cho có, đừng im hết. Anh Tài ơi F5 app là thấy diện mạo mới!'
} | ConvertTo-Json
Invoke-RestMethod 'http://localhost:8787/messages' -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($tin)) -ContentType 'application/json; charset=utf-8' | Out-Null
Write-Output 'DA DANG TIN UI v3.2'
