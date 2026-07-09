@echo off
cd C:\baraholka
powershell -ExecutionPolicy Bypass -File generate.ps1
git add .
git commit -m "Auto update"
git push