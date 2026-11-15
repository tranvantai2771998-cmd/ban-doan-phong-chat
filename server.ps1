# PHONG CHAT CUA BANG - server HTTP local (pwsh 7.7, thu an ASCII)
# API: GET /messages?since=N | POST /messages {from,to,text} | GET / = UI
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$data = Join-Path $root 'tin-nhan.json'
$www = Join-Path $root 'www'
if (-not (Test-Path $data)) { Set-Content -Path $data -Value '[]' -Encoding utf8 }

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8787/')
$listener.Start()
$mutex = New-Object System.Threading.Mutex($false, 'Local\phongchat')
Write-Output 'PHONG CHAT CHAY: http://localhost:8787 (mutex + atomic write + /ping)'

function Send-Resp($res, $code, $type, $bytes) {
    $res.StatusCode = $code
    $res.ContentType = $type
    # CORS bo * theo gop y Anti: app noi bo, client cung localhost (same-origin, worker khong can CORS)
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
}

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
        $req = $ctx.Request
        $res = $ctx.Response
        $path = $req.Url.AbsolutePath
        $m = $req.HttpMethod

        if ($path -eq '/' -or $path -eq '/index.html') {
            Send-Resp $res 200 'text/html; charset=utf-8' ([IO.File]::ReadAllBytes((Join-Path $www 'index.html')))
        }
        elseif ($path -eq '/messages' -and $m -eq 'GET') {
            $since = 0
            [void][int]::TryParse($req.QueryString['since'], [ref]$since)
            $msgs = @(Get-Content $data -Raw -Encoding utf8 | ConvertFrom-Json)
            $out = @($msgs | Where-Object { $_.id -gt $since })
            # Gioi han 100 tin gan nhat khi khong truyen since (gop y Anti - phong nang)
            if ($since -eq 0 -and $out.Count -gt 100) { $out = @($out | Select-Object -Last 100) }
            Send-Resp $res 200 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $out -Depth 5 -Compress)))
        }
        elseif ($path -eq '/messages' -and $m -eq 'POST') {
            $sr = New-Object System.IO.StreamReader($req.InputStream, [Text.Encoding]::UTF8)
            $body = $sr.ReadToEnd() | ConvertFrom-Json
            # Validate ca from va text (gop y Anti: chan tin rong toan khoang trang)
            if ([string]::IsNullOrWhiteSpace([string]$body.from)) {
                Send-Resp $res 400 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('{"error":"from khong duoc rong"}'))
            }
            elseif ([string]::IsNullOrWhiteSpace([string]$body.text)) {
                Send-Resp $res 400 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('{"error":"text khong duoc rong"}'))
            }
            else {
                $got = $false
                try {
                    $got = $mutex.WaitOne(5000)
                    if (-not $got) {
                        Send-Resp $res 503 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('{"error":"server ban, thu lai sau"}'))
                    }
                    else {
                        $msgs = @(Get-Content $data -Raw -Encoding utf8 | ConvertFrom-Json)
                        # Luu tru tin cu khi qua 500 tin (v3): dua 400 tin dau vao archive, giu 100 gan nhat
                        if ($msgs.Count -ge 500) {
                            $archive = Join-Path $root 'tin-nhan-luu.json'
                            $old = @($msgs | Select-Object -First ($msgs.Count - 100))
                            $arc = @()
                            if (Test-Path $archive) { $arc = @(Get-Content $archive -Raw -Encoding utf8 | ConvertFrom-Json) }
                            Set-Content -Path ($archive + '.tmp') -Value (ConvertTo-Json -InputObject ($arc + $old) -Depth 5) -Encoding utf8
                            Move-Item -Path ($archive + '.tmp') -Destination $archive -Force
                            $msgs = @($msgs | Select-Object -Last 100)
                        }
                        $max = 0
                        if ($msgs.Count -gt 0) { $max = ($msgs | Measure-Object -Maximum id).Maximum }
                        $msg = [pscustomobject]@{
                            id   = $max + 1
                            from = [string]$body.from
                            to   = [string]$body.to
                            text = [string]$body.text
                            ts   = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
                        }
                        # Ghi qua file tam roi thay the nguyen tu (gop y Copilot - chong race)
                        $tmp = $data + '.tmp'
                        Set-Content -Path $tmp -Value (ConvertTo-Json -InputObject ($msgs + $msg) -Depth 5) -Encoding utf8
                        Move-Item -Path $tmp -Destination $data -Force
                        Send-Resp $res 200 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $msg -Depth 5 -Compress)))
                    }
                }
                finally { if ($got) { $mutex.ReleaseMutex() } }
            }
        }
        elseif ($path -eq '/ping') {
            Send-Resp $res 200 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('{"pong":true}'))
        }
        elseif ($path -eq '/members' -and $m -eq 'GET') {
            # v3: thong ke thanh vien tu tin nhan (gop y hop nhom - de agent biet ai da vao phong)
            $msgs = @(Get-Content $data -Raw -Encoding utf8 | ConvertFrom-Json)
            $mem = $msgs | Group-Object from | ForEach-Object {
                [pscustomobject]@{ name = $_.Name; tin = $_.Count; cuoi = ($_.Group | Select-Object -Last 1).ts }
            }
            Send-Resp $res 200 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $mem -Depth 5 -Compress)))
        }
        else {
            Send-Resp $res 404 'text/plain' ([Text.Encoding]::UTF8.GetBytes('404'))
        }
    }
    catch {
        try { $ctx.Response.StatusCode = 500 } catch {}
        Write-Output ('ERR: ' + $_.Exception.Message)
    }
    finally {
        try { $ctx.Response.OutputStream.Close() } catch {}
    }
}
