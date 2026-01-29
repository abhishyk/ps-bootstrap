# ---------------- CONFIGURATION ----------------
$urls = @{
    "2"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/runner.cmd"
    "3"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/refs/heads/main/FixPrinterRPC.cmd"
    "4"  = "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/da0b2800d9c783e63af33a6178267ac2201adb2a/MAS/All-In-One-Version-KL/MAS_AIO.cmd"
    "5"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/refs/heads/main/SystemInventory.ps1"
    "6"  = "https://github.com/abhishyk/ps-bootstrap/raw/refs/heads/main/HWiNFO64.exe"
     "7"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/refs/heads/main/Create_RestorePoint.cmd"
}

# ---------------- PRESERVED HEADER FUNCTION ----------------
function Show-Header {
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
    Write-Host "=====================================================" -ForegroundColor Gray
}

# ---------------- VISUAL FEEDBACK ----------------
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

# ---------------- UNIVERSAL DOWNLOADER & RUNNER ----------------
function DownloadAndRun {
    param ([string]$url, [string]$label)
    
    $guid = [Guid]::NewGuid().Guid
    $ext = [System.IO.Path]::GetExtension($url).Split('?')[0]
    $tempPath = "$env:TEMP\App_$guid$ext"

    Write-Host "`n[*] Starting Task: $label" -ForegroundColor Yellow
    Write-Host "[*] Loading... (Please wait, this may take a moment)" -ForegroundColor Magenta
    
    try { 
        # Silencing progress for this specific command to boost speed
        Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop -UseBasicParsing
        Write-Host "[*] Download Complete." -ForegroundColor Green
    } catch {
        Write-Host "[!] Download FAILED: Check your internet connection." -ForegroundColor Red
        return
    }

    if (Test-Path $tempPath) {
        Write-Host "[*] Launching Application..." -ForegroundColor Cyan
        
        # Using Start-Process with -Wait ensures the script cleans up ONLY after you close the EXE
        if ($ext -eq ".ps1") {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempPath`"" -Verb RunAs -Wait
        } 
        elseif ($ext -eq ".exe") {
            # HWiNFO can be slow to initialize; -Wait is crucial here
            Start-Process -FilePath $tempPath -Verb RunAs -Wait
        }
        else {
            Start-Process cmd.exe -ArgumentList "/c `"$tempPath`"" -Verb RunAs -Wait
        }
        
        Write-Host "[*] Cleaning up temporary files..." -ForegroundColor Gray
        Remove-Item -Path $tempPath -Force
    }
}

# ---------------- MAIN LOOP ----------------
while ($true) {
    Show-Header # Refreshes screen and ART at the start of every loop
    
    Write-Host "`nSelect Option:" -ForegroundColor Yellow
    Write-Host "0. Exit      1. gpedit       2. NetFixWifi    3. Printer(0x0000011b)" -ForegroundColor White
    Write-Host "4. Activator 5. MyPC_Info 6. HWiNFO64 7. Create restore Point" -ForegroundColor White
    
    Write-Host "`nChoice: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host
    
    if ($choice -eq "0") { exit }
    
    if ($choice -eq "1") { 
       Start-Process "gpedit.msc" -Verb RunAs
    }
    elseif ($urls.ContainsKey($choice)) { 
        # Download and Run happens below the header
        DownloadAndRun -url $urls[$choice] -label "Option $choice"
        Write-Host "`nExecution complete. Press Enter to return to Menu..." -ForegroundColor Gray
        Read-Host
    }
    else {
        Write-Host "Invalid choice! Returning to menu..." -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
}

