# Chua tin-nhan.json bi long mang (flatten) + kiem tra
$data = 'E:\Nha-Em\phong-chat\tin-nhan.json'
$raw = Get-Content $data -Raw -Encoding utf8
$obj = ConvertFrom-Json -InputObject $raw
if ($obj -is [System.Array] -and $obj.Count -ge 1 -and $obj[0] -is [System.Array]) {
    $flat = @($obj[0])
    Write-Output ('PHAT HIEN LONG — flatten: ' + $flat.Count + ' tin')
    Set-Content -Path ($data + '.tmp') -Value (ConvertTo-Json -InputObject $flat -Depth 5) -Encoding utf8
    Move-Item -Path ($data + '.tmp') -Destination $data -Force
    Write-Output 'DA GHI LAI FLAT'
} else {
    Write-Output ('TEP ON — kieu: ' + $obj.GetType().Name + ' | so phan tu: ' + @($obj).Count)
}
# Xac minh cuoi
$v = @(Get-Content $data -Raw -Encoding utf8 | ConvertFrom-Json)
Write-Output ('XAC MINH: ' + $v.Count + ' tin | id dau: ' + $v[0].id + ' | id cuoi: ' + ($v | Select-Object -Last 1).id)
