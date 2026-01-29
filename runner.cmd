@echo off
:: Automatically get Admin Rights
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~dp0"" && ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

title Deep Network Repair Tool
echo =============================================
echo        STARTING DEEP NETWORK REPAIR
echo =============================================

:: 1. Reset the Network Stack
echo [1/4] Resetting Winsock and TCP/IP...
netsh winsock reset >nul
netsh int ip reset >nul

:: 2. Flush and Clear DNS
echo [2/4] Clearing DNS and ARP Cache...
ipconfig /flushdns >nul
ipconfig /registerdns >nul
arp -d * >nul

:: 3. IP Address Release/Renew
echo [3/4] Releasing and Renewing IP Address...
ipconfig /release >nul
ipconfig /renew >nul

:: 4. Hardware Power-Cycle (Wi-Fi)
echo [4/4] Restarting Wi-Fi Adapter...
:: Note: This assumes your adapter is named "Wi-Fi" (Windows Default)
netsh interface set interface "Wi-Fi" admin=disable
timeout /t 3 /nobreak >nul
netsh interface set interface "Wi-Fi" admin=enable

echo =============================================
echo REPAIR COMPLETE! 
echo.
echo If "Can't connect" persists, please RESTART PC.
echo =============================================
pause
