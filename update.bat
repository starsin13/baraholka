@echo off
cd C:\baraholka

powershell -ExecutionPolicy Bypass -File generate.ps1

if errorlevel 1 (
    echo Generate error!
    pause
    exit /b
)

git add .
git commit -m "Auto update"
git push