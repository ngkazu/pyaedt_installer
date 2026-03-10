@echo off
setlocal enabledelayedexpansion

:: -------------------------------------------------------
:: Find the ANSYSEM_ROOTxxx variable with the highest version number
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
    echo [ERROR] ANSYSEM_ROOT not found. Please install ANSYS Electronics Desktop.
    pause
    exit /b 1
)

if %MAX_VER% LSS 232 (
    echo [ERROR]: ANSYSEM_ROOT%MAX_VER% is not a supported version. Version v232 or later is required.
    pause
    exit /b 1
)

echo [INFO]: ANSYSEM_ROOT%MAX_VER% = %ANSYSEM_PATH%

:: -------------------------------------------------------
:: Create a venv using the Python bundled with the detected ANSYS installation
:: -------------------------------------------------------
set "ANSYS_PYTHON=%ANSYSEM_PATH%\commonfiles\CPython\3_10\winx64\Release\python\python.exe"

if not exist "%ANSYS_PYTHON%" (
    echo [ERROR]: Python not found: %ANSYS_PYTHON%
    pause
    exit /b 1
)

if not exist "%APPDATA%\.pyaedt_env" (
    mkdir "%APPDATA%\.pyaedt_env"
)
cd /d "%APPDATA%\.pyaedt_env"
if exist ".\3_10" (
    echo [INFO]: Removing existing virtual environment...
    rmdir /s /q ".\3_10"
)
echo [INFO]: Creating virtual environment...
"%ANSYS_PYTHON%" -m venv .\3_10
call .\3_10\Scripts\activate.bat

echo [INFO]: Setting up pyaedt environment...
pip --default-timeout=1000 install uv
uv pip install --upgrade pip
uv pip install wheel
uv pip install pyaedt[all]

echo [INFO]: pyaedt environment setup completed.