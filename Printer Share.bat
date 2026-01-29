@echo off
echo Configuring printer sharing, network discovery, and firewall settings via registry
echo.

:: Enable Network Discovery (LLTD)
reg add "HKLM\Software\Policies\Microsoft\Windows\LLTD" /v AllowLLTDIOOnDomain /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\LLTD" /v AllowLLTDIOOnPublicNet /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\LLTD" /v EnableLLTDIO /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\LLTD" /v AllowRspndrOnDomain /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\LLTD" /v AllowRspndrOnPublicNet /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\LLTD" /v EnableRspndr /t REG_DWORD /d 1 /f

:: Enable File and Printer Sharing through Firewall
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v EnableFirewall /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List" /v 139:TCP /t REG_SZ /d "139:TCP:LocalSubnet:Enabled:File and Printer Sharing" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List" /v 445:TCP /t REG_SZ /d "445:TCP:LocalSubnet:Enabled:File and Printer Sharing" /f

:: Enable Guest Access and Null Sessions for all printers
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v NullSessionShares /t REG_MULTI_SZ /d "*" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v RestrictNullSessAccess /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f

:: Apply Full Control for Everyone on all Printers
for /f "tokens=*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Print\Printers" /s /k /f "*"') do (
    reg add "%%A" /v Permissions /t REG_DWORD /d 2032127 /f
)

:: Restart Services
echo Restarting required services...
net stop spooler
net start spooler
net stop lanmanserver
net start lanmanserver

echo.
echo Printer sharing and network policies configured successfully for all printers.
pause
