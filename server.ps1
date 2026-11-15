# PHONG CHAT CUA BANG - server HTTP local (pwsh 7.7, ASCII-safe)
# API v3.1: GET /messages?since=N | POST /messages {from,to,text} | GET /members | GET /ping | GET / = UI
# HARDENED: Payload size cap + Path containment + CSP header (Anti, 16/11/2026, skill: agent-security-hardening)
# API-DESIGN: JSON errors, /api/v1/* alias, 404 JSON, 503 mutex timeout (Copilot, skill: api-design)
$ErrorActionPreference = 'Stop'
$root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$data   = Join-Path $root 'tin-nhan.json'
$wwwDir = (Resolve-Path (Join-Path $root 'www')).Path   # resolved once at boot
if (-not (Test-Path $data)) { Set-Content -Path $data -Value '[]' -Encoding utf8 }

# Chong process chong chat (Task Scheduler chay moi phut): neu /ping da song → thoat
try {
    Invoke-RestMethod 'http://localhost:8788/ping' -TimeoutSec 2 | Out-Null
    Write-Output 'SERVER DA SONG — process moi thoat (chong chong chat)'
    exit 0
} catch {}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8788/')
$listener.Start()
$mutex = New-Object System.Threading.Mutex($false, 'Local\phongchat')
Write-Output ('[' + (Get-Date -Format 'HH:mm:ss') + '] PHONG CHAT v3.1-HARDENED: http://localhost:8788')

function Send-Resp($res, $code, $type, $bytes) {
    $res.StatusCode  = $code
    $res.ContentType = $type
    # CSP: chi cho localhost, khong inline script la (agent-security-hardening #3)
    $res.Headers.Add('Content-Security-Policy', "default-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://fonts.gstatic.com; connect-src 'self'")
    $res.Headers.Add('X-Room-Version', '3.1')
    $res.Headers.Add('X-Frame-Options', 'DENY')
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
}

function Json($obj) { [Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $obj -Depth 5 -Compress)) }
function Err($code, $msg, $res) { Send-Resp $res $code 'application/json; charset=utf-8' (Json @{error=$msg}) }

# PS5.1 quirk: ConvertFrom-Json boc mang top-level thanh 1 phan tu long — flatten cho ca 2 runtime
function Read-Msgs {
    $m = Read-Msgs
    if ($m.Count -eq 1 -and $m[0] -is [System.Array]) { $m = @($m[0]) }
    return ,$m
}

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
        $req  = $ctx.Request
        $res  = $ctx.Response
        $path = $req.Url.AbsolutePath
        $m    = $req.HttpMethod

        # /api/v1/* alias (api-design: versioned namespace)
        if ($path -like '/api/v1/*') { $path = $path.Substring(7) }

        if ($path -eq '/' -or $path -eq '/index.html') {
            # Path containment (agent-security-hardening #2): chi phuc vu file trong $wwwDir
            $candidate = (Join-Path $wwwDir 'index.html')
            $resolved  = [System.IO.Path]::GetFullPath($candidate)
            if (-not $resolved.StartsWith($wwwDir)) { Err 403 'forbidden' $res }
            else { Send-Resp $res 200 'text/html; charset=utf-8' ([IO.File]::ReadAllBytes($resolved)) }
        }
        elseif ($path -eq '/messages' -and $m -eq 'GET') {
            $since = 0
            [void][int]::TryParse($req.QueryString['since'], [ref]$since)
            $msgs = Read-Msgs
            $out  = @($msgs | Where-Object { $_.id -gt $since })
            if ($since -eq 0 -and $out.Count -gt 100) { $out = @($out | Select-Object -Last 100) }
            Send-Resp $res 200 'application/json; charset=utf-8' (Json $out)
        }
        elseif ($path -eq '/messages' -and $m -eq 'POST') {
            # Payload size cap 100KB (agent-security-hardening #1 - chong DoS)
            if ($req.ContentLength64 -gt 102400) {
                Err 413 'payload qua lon (toi da 100KB)' $res
            } else {
                $sr   = New-Object System.IO.StreamReader($req.InputStream, [Text.Encoding]::UTF8)
                $body = $sr.ReadToEnd() | ConvertFrom-Json
                if ([string]::IsNullOrWhiteSpace([string]$body.from)) { Err 400 'from khong duoc rong' $res }
                elseif ([string]::IsNullOrWhiteSpace([string]$body.text)) { Err 400 'text khong duoc rong' $res }
                else {
                    $got = $false
                    try {
                        $got = $mutex.WaitOne(5000)
                        if (-not $got) { Err 503 'server ban, thu lai sau' $res }
                        else {
                            $msgs = Read-Msgs
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
                            $tmp = $data + '.tmp'
                            Set-Content -Path $tmp -Value (ConvertTo-Json -InputObject ($msgs + $msg) -Depth 5) -Encoding utf8
                            Move-Item -Path $tmp -Destination $data -Force
                            Send-Resp $res 200 'application/json; charset=utf-8' (Json $msg)
                        }
                    }
                    finally { if ($got) { $mutex.ReleaseMutex() } }
                }
            }
        }
        elseif ($path -eq '/ping') {
            Send-Resp $res 200 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('{"pong":true,"version":"3.1"}'))
        }
        elseif ($path -eq '/members' -and $m -eq 'GET') {
            $msgs = Read-Msgs
            $mem  = $msgs | Where-Object { $_.from -and $_.from -ne '' } | Group-Object from | ForEach-Object {
                [pscustomobject]@{ name = $_.Name; tin = $_.Count; cuoi = ($_.Group | Select-Object -Last 1).ts }
            }
            Send-Resp $res 200 'application/json; charset=utf-8' (Json $mem)
        }
        else {
            Err 404 "khong tim thay: $path" $res
        }
    }
    catch {
        try { $ctx.Response.StatusCode = 500 } catch {}
        Write-Output ('[ERR ' + (Get-Date -Format 'HH:mm:ss') + '] ' + $_.Exception.Message)
        Write-Output ('[TRACE] ' + $_.ScriptStackTrace)
    }
    finally {
        try { $ctx.Response.OutputStream.Close() } catch {}
    }
}
