@echo off
chcp 65001 >nul
REM =====================================================
REM Lien ket (symlink) skill toi Kilo Code + Codex (khong Claude).
REM Logic thuc su nam trong sync-skills-windows.ps1.
REM Neu mklink bao loi quyen, hay chay Command Prompt "Run as Administrator"
REM hoac bat "Developer Mode" trong Windows Settings.
REM =====================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-skills-windows.ps1" -Targets Codex,Kilo
pause
