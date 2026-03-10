# -------------------------------------------------------
# Find the ANSYSEM_ROOTxxx variable with the highest version number
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
    Write-Host "[ERROR]: ANSYSEM_ROOT not found. Please install ANSYS Electronics Desktop." -ForegroundColor Red
    Read-Host "Press Enter to continue"
    exit 1
}

if ($maxVer -lt 232) {
    Write-Host "[ERROR]: ANSYSEM_ROOT$maxVer is not a supported version. Version v232 or later is required." -ForegroundColor Red
    Read-Host "Press Enter to continue"
    exit 1
}

Write-Host "[INFO]: ANSYSEM_ROOT$maxVer = $ansysemPath" -ForegroundColor Cyan

# -------------------------------------------------------
# Create a venv using the Python bundled with the detected ANSYS installation
# -------------------------------------------------------
$ansysPython = Join-Path $ansysemPath "commonfiles\CPython\3_10\winx64\Release\python\python.exe"

if (-not (Test-Path $ansysPython)) {
    Write-Host "[ERROR]: Python not found: $ansysPython" -ForegroundColor Red
    Read-Host "Press Enter to continue"
    exit 1
}

$venvRoot = Join-Path $env:APPDATA ".pyaedt_env"
$venvDir  = Join-Path $venvRoot "3_10"

if (-not (Test-Path $venvRoot)) {
    New-Item -ItemType Directory -Path $venvRoot | Out-Null
}

if (Test-Path $venvDir) {
    Write-Host "[INFO]: Removing existing virtual environment..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $venvDir
}

Write-Host "[INFO]: Creating virtual environment..." -ForegroundColor Cyan
& $ansysPython -m venv $venvDir

$activateScript = Join-Path $venvDir "Scripts\Activate.ps1"
. $activateScript

Write-Host "[INFO]: Setting up pyaedt environment..." -ForegroundColor Cyan
pip --default-timeout=1000 install uv
uv pip install --upgrade pip
uv pip install wheel
uv pip install pyaedt[all]

Write-Host "[INFO]: pyaedt environment setup completed." -ForegroundColor Green
