@echo off
setlocal enabledelayedexpansion

:: -------------------------------------------------------
:: ANSYSEM_ROOTxxx の中で xxx が最大のものを取得
:: -------------------------------------------------------
set "MAX_VER=0"
set "ANSYSEM_PATH="

for /f "tokens=1* delims==" %%A in ('set ANSYSEM_ROOT 2^>nul') do (
    set "VAR_NAME=%%A"
    set "NUM=!VAR_NAME:ANSYSEM_ROOT=!"
    if !NUM! GTR !MAX_VER! (
        set "MAX_VER=!NUM!"
        set "ANSYSEM_PATH=%%B"
    )
)

if not defined ANSYSEM_PATH (
    echo [ERROR] ANSYSEM_ROOT が見つかりません。ANSYS Electronics Desktop をインストールしてください。
    pause
    exit /b 1
)

if %MAX_VER% LSS 232 (
    echo [ERROR]: ANSYSEM_ROOT%MAX_VER% は対象外のバージョンです。v232 以上が必要です。
    pause
    exit /b 1
)

echo [INFO]: ANSYSEM_ROOT%MAX_VER% = %ANSYSEM_PATH%

:: -------------------------------------------------------
:: 検出した ANSYS 付属 Python で venv を作成
:: -------------------------------------------------------
set "ANSYS_PYTHON=%ANSYSEM_PATH%\commonfiles\CPython\3_10\winx64\Release\python\python.exe"

if not exist "%ANSYS_PYTHON%" (
    echo [ERROR]: Python が見つかりません: %ANSYS_PYTHON%
    pause
    exit /b 1
)

if not exist "%APPDATA%\.pyaedt_env" (
    mkdir "%APPDATA%\.pyaedt_env"
)
cd /d "%APPDATA%\.pyaedt_env"
if exist ".\3_10" (
    echo [INFO]: 既存の仮想環境を削除しています...
    rmdir /s /q ".\3_10"
)
echo [INFO]: 仮想環境を作成しています...
"%ANSYS_PYTHON%" -m venv .\3_10
call .\3_10\Scripts\activate.bat

echo [INFO]: pyaedt環境を作成しています...
pip --default-timeout=1000 install uv
uv pip install --upgrade pip
uv pip install wheel
uv pip install pyaedt[all]

echo [INFO]: pyaedt環境のセットアップが完了しました。