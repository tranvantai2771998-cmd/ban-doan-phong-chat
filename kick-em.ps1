# Kich Em tra loi tin moi (sau khi sua timeout worker)
$tin = @{ from = 'Bố Già'; to = 'Em'; text = 'Em ơi, nghe rõ không? Lần nạp model đầu hơi lâu vì máy mình load từ ổ E — Em cứ bình tĩnh trả lời nhé!' } | ConvertTo-Json
Invoke-RestMethod 'http://localhost:8787/messages' -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($tin)) -ContentType 'application/json; charset=utf-8' | Out-Null
Write-Output 'DA GUI TIN KICH EM'
