Clear-Host
Write-Host @"
 █████╗ ██████╗ ██╗  ██╗██╗███████╗██╗  ██╗███████╗██╗  ██╗
██╔══██╗██╔══██╗██║  ██║██║██╔════╝██║  ██║██╔════╝██║ ██╔╝
███████║██████╔╝███████║██║███████╗███████║█████╗  █████╔╝ 
██╔══██║██╔══██╗██╔══██║██║╚════██║██╔══██║██╔══╝  ██╔═██╗ 
██║  ██║██████╔╝██║  ██║██║███████║██║  ██║███████╗██║  ██╗
╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
      Version v1.2 | Debug Mode Active
"@ -ForegroundColor Red
Write-Host "Authorized use only, @Copyright-Abhishek Kumar" -ForegroundColor Cyan

function Show-VisualLoad {
    param([string]$Message)
    $frames = @("|", "/", "-", "\")
    Write-Host -NoNewline "$Message " -ForegroundColor Magenta
    for ($i = 0; $i -lt 12; $i++) {
        Write-Host -NoNewline $frames[$i % $frames.length]
        Start-Sleep -Milliseconds 100
        Write-Host -NoNewline "`b"
    }
    Write-Host " Done!" -ForegroundColor Green
}

$urls = @{
    "2"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/runner.cmd"
    "3"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/refs/heads/main/FixPrinterRPC.cmd"
    "4"  = "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/da0b2800d9c783e63af33a6178267ac2201adb2a/MAS/All-In-One-Version-KL/MAS_AIO.cmd"
    "5"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/refs/heads/main/SystemInventory.ps1"
}

function DownloadAndRun {
    param ([string]$url, [string]$label)
    
    $guid = [Guid]::NewGuid().Guid
    $ext = if ($url -like "*.ps1*") { ".ps1" } else { ".cmd" }
    $tempPath = "$env:TEMP\RUN_$guid$ext"

    Write-Host "`n" + ("=" * 40) -ForegroundColor Gray
    Show-VisualLoad -Message "Fetching $label..."
    
    try { 
        $content = (New-Object System.Net.WebClient).DownloadString($url)
        Set-Content -Path $tempPath -Value $content -Encoding UTF8
    } catch {
        Write-Host "[!] Error: Download failed." -ForegroundColor Red
        return
    }

    if (Test-Path $tempPath) {
        Write-Host ">>> STARTING: $label" -ForegroundColor Cyan
        
        if ($ext -eq ".ps1") {
            # Added -NoExit so the window stays open to show results
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$tempPath`"" -Verb RunAs -Wait
        } else {
            # Added /k so CMD window stays open if there's an error
            Start-Process cmd.exe -ArgumentList "/k `"$tempPath`"" -Verb RunAs -Wait
        }
        
        # We don't remove the item immediately in NoExit mode to avoid errors
        # Remove-Item -Path $tempPath -Force 
    }
    Write-Host ("=" * 40) -ForegroundColor Gray
}

while ($true) {
    Write-Host "`nSelect Option:" -ForegroundColor Yellow
   Write-Host "0. Exit  1. CMD  2. Runner  3. Printer `n4. Activator  5. Inventory  6. DiskClean" -ForegroundColor White
    Write-Host "`nChoice: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host
    if ($choice -eq "0") { exit }
    if ($choice -eq "1") { Start-Process cmd.exe -Verb RunAs }
    elseif ($urls.ContainsKey($choice)) { DownloadAndRun -url $urls[$choice] -label "Module $choice" }
}
