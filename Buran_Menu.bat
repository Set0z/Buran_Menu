@echo off
powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0\modules\script.ps1\"' -Verb runAs"