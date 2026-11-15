# TELEGRAM GATEWAY - cau 2 chieu giua Telegram va Phong chung
# San sang 100% — chi cho token: Tao bot qua BotFather (/newbot) → dan token vao
# tệp E:\Nha-Em\phong-chat\telegram-token.txt → chay gateway nay
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$tokFile = Join-Path $root 'telegram-token.txt'
$base = 'http://localhost:8787'

if (-not (Test-Path $tokFile)) {
    Write-Output 'CHUA CO TOKEN — tao bot: Telegram > BotFather > /newbot > dan token vao telegram-token.txt'
    exit 1
}
$token = (Get-Content $tokFile -Raw -Encoding utf8).Trim()
Write-Output 'GATEWAY BAT DAU (Telegram <-> Phong chung 8787)'

$chatFile = Join-Path $root 'telegram-chat-id.txt'
$chatId = $null
if (Test-Path $chatFile) { $chatId = (Get-Content $chatFile -Raw -Encoding utf8).Trim() }
$offset = 0
$since = 0
try { $m0 = Invoke-RestMethod ($base + '/messages?since=0') -TimeoutSec 5; if (@($m0).Count -gt 0) { $since = ($m0 | Measure-Object -Maximum id).Maximum } } catch {}

function Send-Tg($text) {
    if (-not $chatId) { return }
    $b = @{ chat_id = $chatId; text = $text } | ConvertTo-Json
    Invoke-RestMethod ("https://api.telegram.org/bot" + $token + "/sendMessage") -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($b)) -ContentType 'application/json; charset=utf-8' -TimeoutSec 15 | Out-Null
}

while ($true) {
    # Chieu 1: Telegram -> Phong
    try {
        $u = Invoke-RestMethod ("https://api.telegram.org/bot" + $token + "/getUpdates?offset=" + $offset + "&timeout=25") -TimeoutSec 35
        foreach ($upd in $u.result) {
            $offset = $upd.update_id + 1
            if ($upd.message -and $upd.message.text) {
                $chatId = [string]$upd.message.chat.id
                Set-Content -Path $chatFile -Value $chatId -Encoding utf8
                $name = $upd.message.from.first_name
                $tin = @{ from = ($name + ' (Telegram)'); to = 'Cả phòng'; text = [string]$upd.message.text } | ConvertTo-Json
                Invoke-RestMethod ($base + '/messages') -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($tin)) -ContentType 'application/json; charset=utf-8' -TimeoutSec 5 | Out-Null
                Send-Tg ('Da gui vao phong: ' + $upd.message.text)
                Write-Output ('TG->PHONG: ' + $upd.message.text)
            }
        }
    } catch { Start-Sleep 5 }

    # Chieu 2: Phong (to:"Telegram") -> Telegram
    try {
        $msgs = Invoke-RestMethod ($base + '/messages?since=' + $since) -TimeoutSec 5
        foreach ($m in $msgs) {
            if ($m.id -gt $since) { $since = $m.id }
            if ($m.to -eq 'Telegram' -and $m.from -notmatch 'Telegram') {
                Send-Tg ('[' + $m.from + '] ' + $m.text)
                Write-Output ('PHONG->TG: ' + $m.text)
            }
        }
    } catch { Start-Sleep 5 }
    Start-Sleep 1
}
