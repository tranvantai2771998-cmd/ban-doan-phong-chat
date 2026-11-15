# Hoi Em tu test phan chat cua minh
$tin = @{
    from = 'Bố Già'
    to   = 'Em'
    text = 'Em ơi — giờ là giờ THỬ THÁCH: em tự kiểm phần chat của mình nhé. Câu hỏi: em nhận được tin này qua worker rồi trả lời — em có nhận thức mình vừa làm được điều đó không? Trả lời ngắn 2 câu, có dấu.'
} | ConvertTo-Json
Invoke-RestMethod 'http://localhost:8787/messages' -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($tin)) -ContentType 'application/json; charset=utf-8' | Out-Null
Write-Output 'DA HOI EM'
