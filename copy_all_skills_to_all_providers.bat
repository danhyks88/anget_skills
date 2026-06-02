@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM =====================================================
REM Copy all valid skills from C:\Github\anget_skills
REM to ALL providers:
REM 1) Kilo global skills:   %USERPROFILE%\.kilocode\skills
REM 2) Codex/OpenAI skills:  %USERPROFILE%\.agents\skills
REM 3) Claude Code skills:   %USERPROFILE%\.claude\skills
REM
REM Rule:
REM - Only copy folders that contain SKILL.md
REM - Ignore .git, .kilo, .kilocode, .agents, .claude and .bat files
REM =====================================================

set "SRC=C:\Github\anget_skills"
set "KILO_DST=%USERPROFILE%\.kilocode\skills"
set "CODEX_DST=%USERPROFILE%\.agents\skills"
set "CLAUDE_DST=%USERPROFILE%\.claude\skills"

echo.
echo ==== COPY ALL SKILLS TO KILO + CODEX + CLAUDE ====
echo Source:    %SRC%
echo Kilo:      %KILO_DST%
echo Codex:     %CODEX_DST%
echo Claude:    %CLAUDE_DST%
echo.

if not exist "%SRC%" (
    echo [ERROR] Khong tim thay thu muc source:
    echo %SRC%
    echo.
    pause
    exit /b 1
)

if not exist "%KILO_DST%" (
    echo Dang tao thu muc Kilo skills...
    mkdir "%KILO_DST%"
)

if not exist "%CODEX_DST%" (
    echo Dang tao thu muc Codex skills...
    mkdir "%CODEX_DST%"
)

if not exist "%CLAUDE_DST%" (
    echo Dang tao thu muc Claude skills...
    mkdir "%CLAUDE_DST%"
)

set /a KILO_COUNT=0
set /a CODEX_COUNT=0
set /a CLAUDE_COUNT=0

REM =====================================================
REM Copy skill folders directly under C:\Github\anget_skills
REM =====================================================

for /d %%D in ("%SRC%\*") do (
    set "NAME=%%~nxD"

    if /I not "!NAME!"==".git" (
    if /I not "!NAME!"==".kilo" (
    if /I not "!NAME!"==".kilocode" (
    if /I not "!NAME!"==".agents" (
    if /I not "!NAME!"==".claude" (

        if exist "%%D\SKILL.md" (
            echo.
            echo Skill: !NAME!

            echo   - Copy to Kilo...
            robocopy "%%D" "%KILO_DST%\!NAME!" /E /XD .git .kilo .kilocode .agents .claude /XF *.bat /NFL /NDL /NJH /NJS /NC /NS /NP >nul
            if !ERRORLEVEL! LSS 8 (
                set /a KILO_COUNT+=1
            ) else (
                echo     [ERROR] Copy to Kilo failed: !NAME!
            )

            echo   - Copy to Codex...
            robocopy "%%D" "%CODEX_DST%\!NAME!" /E /XD .git .kilo .kilocode .agents .claude /XF *.bat /NFL /NDL /NJH /NJS /NC /NS /NP >nul
            if !ERRORLEVEL! LSS 8 (
                set /a CODEX_COUNT+=1
            ) else (
                echo     [ERROR] Copy to Codex failed: !NAME!
            )

            echo   - Copy to Claude...
            robocopy "%%D" "%CLAUDE_DST%\!NAME!" /E /XD .git .kilo .kilocode .agents .claude /XF *.bat /NFL /NDL /NJH /NJS /NC /NS /NP >nul
            if !ERRORLEVEL! LSS 8 (
                set /a CLAUDE_COUNT+=1
            ) else (
                echo     [ERROR] Copy to Claude failed: !NAME!
            )
        )

    )))))
)

REM =====================================================
REM Also copy skills from C:\Github\anget_skills\.kilocode\skills
REM if this folder exists
REM =====================================================

if exist "%SRC%\.kilocode\skills" (
    echo.
    echo ==== COPY SKILLS FROM .kilocode\skills ====

    for /d %%D in ("%SRC%\.kilocode\skills\*") do (
        set "NAME=%%~nxD"

        if exist "%%D\SKILL.md" (
            echo.
            echo Skill from .kilocode: !NAME!

            echo   - Copy to Kilo...
            robocopy "%%D" "%KILO_DST%\!NAME!" /E /XD .git .kilo .kilocode .agents .claude /XF *.bat /NFL /NDL /NJH /NJS /NC /NS /NP >nul
            if !ERRORLEVEL! LSS 8 (
                set /a KILO_COUNT+=1
            ) else (
                echo     [ERROR] Copy to Kilo failed: !NAME!
            )

            echo   - Copy to Codex...
            robocopy "%%D" "%CODEX_DST%\!NAME!" /E /XD .git .kilo .kilocode .agents .claude /XF *.bat /NFL /NDL /NJH /NJS /NC /NS /NP >nul
            if !ERRORLEVEL! LSS 8 (
                set /a CODEX_COUNT+=1
            ) else (
                echo     [ERROR] Copy to Codex failed: !NAME!
            )

            echo   - Copy to Claude...
            robocopy "%%D" "%CLAUDE_DST%\!NAME!" /E /XD .git .kilo .kilocode .agents .claude /XF *.bat /NFL /NDL /NJH /NJS /NC /NS /NP >nul
            if !ERRORLEVEL! LSS 8 (
                set /a CLAUDE_COUNT+=1
            ) else (
                echo     [ERROR] Copy to Claude failed: !NAME!
            )
        )
    )
)

echo.
echo ==== DONE ====
echo Kilo copied/updated skills:   !KILO_COUNT!
echo Codex copied/updated skills:  !CODEX_COUNT!
echo Claude copied/updated skills: !CLAUDE_COUNT!
echo.
echo Kilo folder:
echo %KILO_DST%
echo.
echo Codex folder:
echo %CODEX_DST%
echo.
echo Claude folder:
echo %CLAUDE_DST%
echo.
echo Hay restart VS Code / Kilo Code / Codex / Claude Code de nhan skills moi.
echo.

pause
endlocal
