@echo off
chcp 65001 >nul
title Pale Coins - Simplified Chinese Localization - Uninstall
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1" %*
if errorlevel 1 pause
