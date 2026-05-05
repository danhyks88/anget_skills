@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM OpenViking Auto Setup for Windows - no admin required
REM What it does:
REM 1. Creates C:\venvs\openviking if missing
REM 2. Sets short TEMP/TMP/PIP cache paths to avoid long-path issues
REM 3. Creates a Python virtual environment
REM 4. Installs or updates OpenViking
REM 5. Runs openviking-server init and doctor
REM ============================================================

title OpenViking Auto Setup
chcp 65001 >nul

set "VENV_ROOT=C:\venvs"
set "VENV_PATH=C:\venvs\openviking"
set "TMP_PATH=C:\venvs\tmp"
set "PIP_CACHE=C:\venvs\pip-cache"

set "PYTHON_EXE=%VENV_PATH%\Scripts\python.exe"
set "OPENVIKING_SERVER=%VENV_PATH%\Scripts\openviking-server.exe"

echo.
echo ============================================================
echo OpenViking Auto Setup
echo ============================================================
echo.

REM Create folders
if not exist "%VENV_ROOT%" mkdir "%VENV_ROOT%"
if not exist "%TMP_PATH%" mkdir "%TMP_PATH%"
if not exist "%PIP_CACHE%" mkdir "%PIP_CACHE%"

REM Use short paths to reduce Windows long-path problems
set "TEMP=%TMP_PATH%"
set "TMP=%TMP_PATH%"
set "PIP_CACHE_DIR=%PIP_CACHE%"

echo TEMP=%TEMP%
echo TMP=%TMP%
echo PIP_CACHE_DIR=%PIP_CACHE_DIR%
echo.

REM Find Python command
set "BASE_PYTHON="

where py >nul 2>nul
if %ERRORLEVEL%==0 (
    set "BASE_PYTHON=py -3"
) else (
    where python >nul 2>nul
    if %ERRORLEVEL%==0 (
        set "BASE_PYTHON=python"
    )
)

if "%BASE_PYTHON%"=="" (
    echo [ERROR] Python was not found.
    echo Please install Python 3.10+ first, then run this file again.
    echo Recommended: install Python for current user only.
    echo.
    pause
    exit /b 1
)

echo Found Python command: %BASE_PYTHON%
echo.

REM Create venv if missing
if not exist "%PYTHON_EXE%" (
    echo Creating virtual environment at %VENV_PATH% ...
    %BASE_PYTHON% -m venv "%VENV_PATH%"
    if errorlevel 1 (
        echo.
        echo [ERROR] Failed to create virtual environment.
        echo Try checking your Python installation or permission to write to C:\venvs.
        echo.
        pause
        exit /b 1
    )
) else (
    echo Virtual environment already exists: %VENV_PATH%
)

echo.
echo Checking venv Python...
"%PYTHON_EXE%" -c "import sys; print(sys.executable)"
if errorlevel 1 (
    echo.
    echo [ERROR] Venv Python is not working.
    echo.
    pause
    exit /b 1
)

echo.
echo Upgrading pip, setuptools, wheel...
"%PYTHON_EXE%" -m pip install --upgrade pip setuptools wheel
if errorlevel 1 (
    echo.
    echo [ERROR] Failed to upgrade pip/setuptools/wheel.
    echo.
    pause
    exit /b 1
)

echo.
echo Checking OpenViking...
if not exist "%OPENVIKING_SERVER%" (
    echo OpenViking not found. Installing OpenViking...
    "%PYTHON_EXE%" -m pip install openviking --upgrade --force-reinstall --no-cache-dir
    if errorlevel 1 (
        echo.
        echo [ERROR] Failed to install OpenViking.
        echo Common causes:
        echo - Company firewall/proxy blocks pip download
        echo - Python version is not compatible
        echo - Windows path is still too long
        echo.
        pause
        exit /b 1
    )
) else (
    echo OpenViking already exists. Updating OpenViking...
    "%PYTHON_EXE%" -m pip install openviking --upgrade --no-cache-dir
    if errorlevel 1 (
        echo.
        echo [WARNING] OpenViking update failed, but existing installation may still work.
        echo Continuing...
    )
)

echo.
echo Verifying openviking-server...
"%OPENVIKING_SERVER%" --help >nul
if errorlevel 1 (
    echo.
    echo [ERROR] openviking-server was not found or is not working.
    echo Expected path:
    echo %OPENVIKING_SERVER%
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo OpenViking installed successfully.
echo Path: %OPENVIKING_SERVER%
echo ============================================================
echo.

echo Running openviking-server init...
"%OPENVIKING_SERVER%" init
if errorlevel 1 (
    echo.
    echo [WARNING] openviking-server init returned an error.
    echo You can run it again manually:
    echo "%OPENVIKING_SERVER%" init
    echo.
) else (
    echo init completed.
)

echo.
echo Running openviking-server doctor...
"%OPENVIKING_SERVER%" doctor
if errorlevel 1 (
    echo.
    echo [WARNING] openviking-server doctor found issues.
    echo Read the messages above and fix provider/config settings if needed.
    echo.
) else (
    echo doctor completed.
)

echo.
echo ============================================================
echo DONE.
echo To run OpenViking later, use:
echo "%OPENVIKING_SERVER%"
echo ============================================================
echo.

pause
exit /b 0
