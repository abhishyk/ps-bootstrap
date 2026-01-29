@echo off
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:: PC NAME CHANGER SECTION
:=====================================================================
cls
echo.
echo =========================================
echo       WINDOWS COMPUTER NAME CHANGER
echo =========================================
echo.
SET /P PCNAME=PLEASE ENTER YOUR DESIRED COMPUTER NAME: 

echo Changing computer name to: %PCNAME%...

:: Apply name change to Registry
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName /v ComputerName /t REG_SZ /d %PCNAME% /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\ /v ComputerName /t REG_SZ /d %PCNAME% /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ /v Hostname /t REG_SZ /d %PCNAME% /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ /v "NV Hostname" /t REG_SZ /d %PCNAME% /f

echo.
echo Success! The name has been updated in the registry.
echo NOTE: You MUST restart your computer for the changes to take effect.
echo.
pause
