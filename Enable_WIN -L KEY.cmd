@echo off
set /p choice="Do you want to enable or disable Lock Workstation? (enable/disable): "

if /i "%choice%"=="enable" (
    set value=0
) else if /i "%choice%"=="disable" (
    set value=1
) else (
    echo Invalid choice. Please enter 'enable' or 'disable'.
    exit /b 1
)

echo Setting registry value...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableLockWorkstation /t REG_DWORD /d %value% /f
if %errorlevel% equ 0 (
    echo Registry value set successfully.
) else (
    echo Failed to set registry value.
)
pause

