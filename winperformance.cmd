@echo off
title Windows Performance Test

echo Running Windows System Assessment Tool...
echo Please wait...
echo.

winsat formal

echo.
echo Assessment Complete!
echo.
echo Retrieving Scores...
echo.

powershell -Command "Get-CimInstance Win32_WinSAT | Select CPUScore, MemoryScore, GraphicsScore, D3DScore, DiskScore, WinSPRLevel"

echo.
pause