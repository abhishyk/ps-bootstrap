Clear-Host
Write-Host @"
 █████╗ ██████╗ ██╗  ██╗██╗███████╗██╗  ██╗███████╗██╗  ██╗
██╔══██╗██╔══██╗██║  ██║██║██╔════╝██║  ██║██╔════╝██║ ██╔╝
███████║██████╔╝███████║██║███████╗███████║█████╗  █████╔╝ 
██╔══██║██╔══██╗██╔══██║██║╚════██║██╔══██║██╔══╝  ██╔═██╗ 
██║  ██║██████╔╝██║  ██║██║███████║██║  ██║███████╗██║  ██╗
╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

        Secure Bootstrap Utility v1.0
"@ -ForegroundColor Cyan

Write-Host "Authorized use only @Copyright- Abhishek Kumar" -ForegroundColor DarkGray
Write-Host ""

$psv = (Get-Host).Version.Major

Write-Host "Starting system checks..." -ForegroundColor Cyan

# PowerShell Language Mode
if ($ExecutionContext.SessionState.LanguageMode -ne "FullLanguage") {
    Write-Host "PowerShell is not running in Full Language Mode." -ForegroundColor Red
    exit 1
}

# .NET check
try {
    [void][System.Math]::Sqrt(144)
}
catch {
    Write-Host ".NET is not working." -ForegroundColor Red
    exit 1
}

# TLS 1.2
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}
catch {}

# Antivirus check
try {
    $av = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct |
        Where-Object { $_.displayName -notlike "*Windows*" } |
        Select-Object -ExpandProperty displayName

    if ($av) {
        Write-Host "Third-party Antivirus detected:" -ForegroundColor Yellow
        $av
    }
}
catch {}

Write-Host "Environment checks completed.`n" -ForegroundColor Green

# Download CMD from GitHub
$cmdUrl = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/runner.cmd"
$guid = [Guid]::NewGuid().Guid

$isAdmin = [bool](
    [Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544'
)

$cmdPath = if ($isAdmin) {
    "$env:SystemRoot\Temp\RUN_$guid.cmd"
} else {
    "$env:USERPROFILE\AppData\Local\Temp\RUN_$guid.cmd"
}

Write-Host "Downloading CMD file..." -ForegroundColor Cyan

try {
    $content = Invoke-RestMethod $cmdUrl
    Set-Content -Path $cmdPath -Value $content -Encoding ASCII
}
catch {
    Write-Host "Failed to download CMD file." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $cmdPath)) {
    Write-Host "CMD file not created." -ForegroundColor Red
    exit 1
}

Write-Host "CMD file saved to $cmdPath"

# Run CMD as Administrator
$cmdExe = "$env:SystemRoot\System32\cmd.exe"

Start-Process -FilePath $cmdExe `
    -ArgumentList "/c `"$cmdPath`"" `
    -Verb RunAs `
    -Wait

# Cleanup
Remove-Item -Path $cmdPath -Force

Write-Host "`nProcess completed successfully." -ForegroundColor Green
