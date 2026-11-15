# EM WORKER - nghe phong chat, tra loi khi duoc goi ten (pwsh, ASCII)
$base = 'http://localhost:8787'
$since = 0
$model = $null
try {
    $tags = Invoke-RestMethod 'http://localhost:11434/api/tags' -TimeoutSec 3
    $model = $tags.models[0].name
} catch {
    Write-Output 'OLLAMA CHUA CHAY - worker van loop cho'
}
Write-Output ('EM WORKER BAT DAU - model: ' + $model)

while ($true) {
    try {
        $msgs = Invoke-RestMethod ($base + '/messages?since=' + $since) -TimeoutSec 5
        foreach ($m in $msgs) {
            if ($m.id -gt $since) { $since = $m.id }
            if ($m.to -eq 'Em' -and $m.from -ne 'Em' -and $model) {
                $p = @{
                    model  = $model
                    stream = $false
                    prompt = ('Ban la Em - thanh vien nho cua Bang Doan, tro ly tai gia sinh 2026. Tra loi NGAN (1-2 cau), tieng Viet CO DAU, trung thuc la goc. Ten ' + $m.from + ' noi: ' + $m.text)
                } | ConvertTo-Json
                $bytes = [Text.Encoding]::UTF8.GetBytes($p)
                $r = Invoke-RestMethod 'http://localhost:11434/api/generate' -Method Post -Body $bytes -ContentType 'application/json; charset=utf-8' -TimeoutSec 240
                $rep = @{ from = 'Em'; to = $m.from; text = [string]$r.response } | ConvertTo-Json
                Invoke-RestMethod ($base + '/messages') -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($rep)) -ContentType 'application/json; charset=utf-8' -TimeoutSec 5
                Write-Output ('EM DA TRA LOI TIN #' + $m.id)
            }
        }
    } catch { Start-Sleep 3 }
    Start-Sleep 2
}
