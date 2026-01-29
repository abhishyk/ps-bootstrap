@echo off
set /p action=Enter 'enable' or 'disable': 

if /i "%action%"=="enable" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" /v "Start" /t REG_DWORD /d 3 /f
    echo USB storage devices enabled.
) else if /i "%action%"=="disable" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" /v "Start" /t REG_DWORD /d 4 /f
    echo USB storage devices disabled.
) else (
    echo Invalid action. Please enter 'enable' or 'disable'.
)

pause
