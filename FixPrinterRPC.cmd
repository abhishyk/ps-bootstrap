@echo off
echo Fixing Printer RPC Privacy Issue...

:: Add registry key to disable RPC privacy
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f

:: Restart Print Spooler service
echo Restarting Print Spooler service...
net stop spooler
net start spooler

echo Done! Printer RPC Privacy Issue should be fixed.
pause
