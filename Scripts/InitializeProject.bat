@echo off
REM Initializes the Godot starter template using the PowerShell script.
set SCRIPT_DIR=%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%InitializeProject.ps1" %*
