# BO TEST PHONG CHAT - Bo Gia lam QA (PASS/FAIL tung case)
$base = 'http://localhost:8787'
$kq = @()
function Test-Case($ten, $script) {
    try {
        $ok = & $script
        if ($ok) { Write-Output ('PASS — ' + $ten); return $true } else { Write-Output ('FAIL — ' + $ten); return $false }
    } catch { Write-Output ('FAIL — ' + $ten + ' | ' + $_.Exception.Message); return $false }
}

# T1: UI tra 200 va co chu phong
Test-Case 'T1 UI dang tai (200 + co ten phong)' {
    $r = Invoke-WebRequest ($base + '/') -TimeoutSec 5 -UseBasicParsing
    ($r.StatusCode -eq 200 -and $r.Content -match 'Phòng chung')
}

# T2: POST tieng Viet giu nguyen dau
Test-Case 'T2 POST tieng Viet khong mat dau' {
    $m = Invoke-RestMethod ($base + '/messages') -Method Post -Body ([Text.Encoding]::UTF8.GetBytes('{"from":"Bố Già","to":"Cả phòng","text":"Bài test: Phòng chat phải giữ dấu tiếng Việt — Sức khỏe, Gia Định."}')) -ContentType 'application/json; charset=utf-8' -TimeoutSec 5
    $m.text -match 'Sức khỏe, Gia Định'
}

# T3: GET since thay tin vua post
Test-Case 'T3 GET since=N tra tin moi' {
    $all = Invoke-RestMethod ($base + '/messages?since=0') -TimeoutSec 5
    @($all).Count -ge 2
}

# T4: POST tin dai 1000 ky tu
Test-Case 'T4 POST tin dai 1000 ky tu khong vo' {
    $s = 'y' * 1000
    $m = Invoke-RestMethod ($base + '/messages') -Method Post -Body ([Text.Encoding]::UTF8.GetBytes('{"from":"Bố Già","text":"' + $s + '"}')) -ContentType 'application/json; charset=utf-8' -TimeoutSec 5
    $m.text.Length -eq 1000
}

# T5: POST from rong — PHAI BI CHAN (400) theo hop dong moi
Test-Case 'T5 POST from rong — BI CHAN 400 (sửa theo góp ý Copilot)' {
    try {
        Invoke-RestMethod ($base + '/messages') -Method Post -Body ([Text.Encoding]::UTF8.GetBytes('{"from":"","text":"test"}')) -ContentType 'application/json; charset=utf-8' -TimeoutSec 5
        $false
    } catch { $_.Exception.Response.StatusCode.value__ -eq 400 }
}

# T6: GET /ping — PHAI CO (health endpoint đã thêm)
Test-Case 'T6 GET /ping — TỒN TẠI (health endpoint)' {
    $p = Invoke-RestMethod ($base + '/ping') -TimeoutSec 3
    $p.pong -eq $true
}

# T7: GET tin qua since lon — tra rong chu khong loi
Test-Case 'T7 GET since=999999 tra rong khong loi' {
    $g = Invoke-RestMethod ($base + '/messages?since=999999') -TimeoutSec 5
    @($g).Count -eq 0
}
Write-Output ('=== BO TEST CHAY XONG LUC ' + (Get-Date -Format 'HH:mm:ss') + ' ===')
