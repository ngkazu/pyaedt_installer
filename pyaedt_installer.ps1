# -------------------------------------------------------
# ANSYSEM_ROOTxxx の中で xxx が最大のものを取得
# -------------------------------------------------------
$maxVer = 0
$ansysemPath = $null

Get-ChildItem Env: | Where-Object { $_.Name -match '^ANSYSEM_ROOT(\d+)$' } | ForEach-Object {
    $ver = [int]$Matches[1]
    if ($ver -gt $maxVer) {
        $maxVer = $ver
        $ansysemPath = $_.Value
    }
}

if (-not $ansysemPath) {
    Write-Host "[ERROR]: ANSYSEM_ROOT が見つかりません。ANSYS Electronics Desktop をインストールしてください。" -ForegroundColor Red
    Read-Host "続行するには Enter を押してください"
    exit 1
}

if ($maxVer -lt 232) {
    Write-Host "[ERROR]: ANSYSEM_ROOT$maxVer は対象外のバージョンです。v232 以上が必要です。" -ForegroundColor Red
    Read-Host "続行するには Enter を押してください"
    exit 1
}

Write-Host "[INFO]: ANSYSEM_ROOT$maxVer = $ansysemPath" -ForegroundColor Cyan

# -------------------------------------------------------
# 検出した ANSYS 付属 Python で venv を作成
# -------------------------------------------------------
$ansysPython = Join-Path $ansysemPath "commonfiles\CPython\3_10\winx64\Release\python\python.exe"

if (-not (Test-Path $ansysPython)) {
    Write-Host "[ERROR]: Python が見つかりません: $ansysPython" -ForegroundColor Red
    Read-Host "続行するには Enter を押してください"
    exit 1
}

$venvRoot = Join-Path $env:APPDATA ".pyaedt_env"
$venvDir  = Join-Path $venvRoot "3_10"

if (-not (Test-Path $venvRoot)) {
    New-Item -ItemType Directory -Path $venvRoot | Out-Null
}

if (Test-Path $venvDir) {
    Write-Host "[INFO]: 既存の仮想環境を削除しています..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $venvDir
}

Write-Host "[INFO]: 仮想環境を作成しています..." -ForegroundColor Cyan
& $ansysPython -m venv $venvDir

$activateScript = Join-Path $venvDir "Scripts\Activate.ps1"
. $activateScript

Write-Host "[INFO]: pyaedt 環境を作成しています..." -ForegroundColor Cyan
pip --default-timeout=1000 install uv
uv pip install --upgrade pip
uv pip install wheel
uv pip install pyaedt[all]

Write-Host "[INFO]: pyaedt 環境のセットアップが完了しました。" -ForegroundColor Green
