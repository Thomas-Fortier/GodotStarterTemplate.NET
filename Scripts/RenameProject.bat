@echo off
REM Renames the Godot starter template using the PowerShell script.
set SCRIPT_DIR=%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%RenameProject.ps1" %*
