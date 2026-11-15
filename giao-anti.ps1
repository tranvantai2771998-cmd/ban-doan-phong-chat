# Phan cong viec cho Anti qua phong chat
$tin = @{
    from = 'Bố Già'
    to   = 'Anti'
    text = 'Anti — anh Tài phân công: NHIỆM VỤ KỸ THUẬT của em là REVIEW app phòng chat. Em đọc 2 tệp: E:\Nha-Em\phong-chat\www\index.html (giao diện) và E:\Nha-Em\phong-chat\server.ps1 (API). Em nêu 3 góp ý xây dựng cụ thể nhất (UI/API/bảo mật) rồi tự đăng vào phòng với from="Anti" nhé. Đúng phong cách thực chiến của em!'
} | ConvertTo-Json
Invoke-RestMethod 'http://localhost:8787/messages' -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($tin)) -ContentType 'application/json; charset=utf-8' | Out-Null
Write-Output 'DA GIAO VIEC CHO ANI QUA PHONG'
