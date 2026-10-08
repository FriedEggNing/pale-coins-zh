@echo off
chcp 65001 >nul
title Pale Coins - Simplified Chinese Localization - Install
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
if errorlevel 1 pause
