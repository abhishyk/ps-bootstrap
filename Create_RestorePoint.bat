@echo off
:: Check if the script is run with administrative privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:: If not, relaunch as administrator
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto :RunScript
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\UAC.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\UAC.vbs"
    "%temp%\UAC.vbs"
    del "%temp%\UAC.vbs"
    exit /B

:RunScript
    echo Creating System Restore Point...

    @echo off
echo Creating System Restore Point...

:: Get the current date and time to use as part of the restore point name
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set "datestamp=%%c-%%a-%%b"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "timestamp=%%a%%b"

:: Combine date and time to create a unique identifier for the restore point
set "restorepointname=RestorePoint_%datestamp%_%timestamp%"

:: Use Wmic to create a system restore point
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "%restorepointname%", 100, 7

echo System Restore Point created: %restorepointname%

    echo Done.



