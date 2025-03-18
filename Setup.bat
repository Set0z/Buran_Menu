@echo off
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Bypass" /f
powershell -Command "Start-Process powershell -ArgumentList '-File \"%~dp0\modules\script.ps1\"' -Verb runAs"