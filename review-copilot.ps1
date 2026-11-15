# Copilot review doan POST cua server (here-string giu nguyen code)
$code = @'
[void]$mutex.WaitOne(5000)
try {
  $msgs = @(Get-Content $data -Raw -Encoding utf8 | ConvertFrom-Json)
  $max = 0; if ($msgs.Count -gt 0) { $max = ($msgs | Measure-Object -Maximum id).Maximum }
  $msg = [pscustomobject]@{ id = $max+1; from=[string]$body.from; to=[string]$body.to; text=[string]$body.text; ts=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss') }
  $tmp = $data + '.tmp'
  Set-Content -Path $tmp -Value (ConvertTo-Json -InputObject ($msgs + $msg) -Depth 5) -Encoding utf8
  Move-Item -Path $tmp -Destination $data -Force
} finally { $mutex.ReleaseMutex() }
'@
$vinh = "NHIEM VU CODE REVIEW - chat server PowerShell luu tin vao JSON, da co Mutex va atomic write. Code xu ly POST:" + $code + "Tra loi NGAN dung tieng Viet CO DAU, dung 3 gach dau dong: (1) con loi hoac rui ro nao con sot, (2) mot cai thien dang lam ngay, (3) cham diem 1-10 cho doan nay."
$env:GH_TOKEN = (& "$env:ProgramFiles\GitHub CLI\gh.exe" auth token).Trim()
& "$env:LOCALAPPDATA\GitHubCopilotCLI\copilot.exe" -p $vinh 2>&1 | Where-Object { $_ -and ($_ -notmatch 'Copilot Fusion|AI Credits|Tokens|Resume|Changes') } | Select-Object -First 10
