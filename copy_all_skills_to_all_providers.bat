@echo off
chcp 65001 >nul
REM =====================================================
REM Lien ket (symlink) toan bo skill toi CA 3 provider:
REM Claude Code, Codex, Kilo Code - va chen skill bat buoc
REM (vietnamese-short-answer) vao cau hinh chung cua ca 3.
REM
REM Logic thuc su nam trong sync-skills-windows.ps1 (de doc/sua hon batch).
REM Neu mklink bao loi quyen, hay chay Command Prompt "Run as Administrator"
REM hoac bat "Developer Mode" trong Windows Settings.
REM =====================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-skills-windows.ps1" -Targets Claude,Codex,Kilo
pause
