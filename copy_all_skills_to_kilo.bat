@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ==========================================
REM Copy all skills from C:\Github\anget_skills
REM to Kilo global skills folder:
REM %USERPROFILE%\.kilocode\skills
REM ==========================================

set "SRC=C:\Github\anget_skills"
set "DST=%USERPROFILE%\.kilocode\skills"

echo.
echo ==== COPY ALL SKILLS TO KILO ====
echo Source:      %SRC%
echo Destination: %DST%
echo.

if not exist "%SRC%" (
    echo [ERROR] Khong tim thay thu muc source: %SRC%
    echo Kiem tra lai duong dan C:\Github\anget_skills
    pause
    exit /b 1
)

if not exist "%DST%" (
    echo Dang tao thu muc Kilo skills...
    mkdir "%DST%"
)

set "COUNT=0"

REM Copy skill folders directly under C:\Github\anget_skills if they contain SKILL.md
for /d %%D in ("%SRC%\*") do (
    if /I not "%%~nxD"==".kilocode" (
        if exist "%%D\SKILL.md" (
            echo Copy skill: %%~nxD
            robocopy "%%D" "%DST%\%%~nxD" /E /NFL /NDL /NJH /NJS /NC /NS /NP >nul
            set /a COUNT+=1
        )
    )
)

REM Also copy skills from C:\Github\anget_skills\.kilocode\skills if this folder exists
if exist "%SRC%\.kilocode\skills" (
    for /d %%D in ("%SRC%\.kilocode\skills\*") do (
        if exist "%%D\SKILL.md" (
            echo Copy skill from .kilocode: %%~nxD
            robocopy "%%D" "%DST%\%%~nxD" /E /NFL /NDL /NJH /NJS /NC /NS /NP >nul
            set /a COUNT+=1
        )
    )
)

echo.
echo Done. Total copied/updated skills: !COUNT!
echo Kilo skills folder: %DST%
echo.
echo Hay restart VS Code / Kilo Code de nhan skill moi.
echo.
pause
endlocal
