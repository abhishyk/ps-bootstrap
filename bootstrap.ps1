Clear-Host
Write-Host @"
 █████╗ ██████╗ ██╗  ██╗██╗███████╗██╗  ██╗███████╗██╗  ██╗
██╔══██╗██╔══██╗██║  ██║██║██╔════╝██║  ██║██╔════╝██║ ██╔╝
███████║██████╔╝███████║██║███████╗███████║█████╗  █████╔╝ 
██╔══██║██╔══██╗██╔══██║██║╚════██║██╔══██║██╔══╝  ██╔═██╗ 
██║  ██║██████╔╝██║  ██║██║███████║██║  ██║███████╗██║  ██╗
╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
      Version v1.0 | Enhanced UI
"@ -ForegroundColor Red
Write-Host "Authorized use only,@Copyright-Abhishek Kumar" -ForegroundColor Cyan
# ---------------- HELPER: ANIMATION ----------------
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

# ---------------- SYSTEM CHECKS ----------------
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
if ($ExecutionContext.SessionState.LanguageMode -ne "FullLanguage") { exit 1 }
try { [void][System.Math]::Sqrt(144) } catch { exit 1 }

# Antivirus check
try {
    $av = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct |
        Where-Object { $_.displayName -notlike "*Windows*" } | Select-Object -ExpandProperty displayName
    if ($av) { Write-Host "[!] Security: $av detected" -ForegroundColor Yellow }
} catch {}

Write-Host "System Ready.`n" -ForegroundColor Green

# ---------------- CONFIGURATION ----------------
$cmdExe = "$env:SystemRoot\System32\cmd.exe"
$urls = @{
    "2"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/runner.cmd"
    "3"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/refs/heads/main/FixPrinterRPC.cmd"
    "4"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/script2.cmd"
    "5"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/script3.cmd"
    "6"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/script4.cmd"
    "7"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/script5.cmd"
    "8"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/script6.cmd"
    "9"  = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/script7.cmd"
    "10" = "https://raw.githubusercontent.com/abhishyk/ps-bootstrap/main/script8.cmd"
}

# ---------------- CORE FUNCTION ----------------
function DownloadAndRun {
    param ([string]$url, [string]$label)
    
    $guid = [Guid]::NewGuid().Guid
    $isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
    $cmdPath = if ($isAdmin) { "$env:SystemRoot\Temp\RUN_$guid.cmd" } else { "$env:USERPROFILE\AppData\Local\Temp\RUN_$guid.cmd" }

    Write-Host "`n" + ("=" * 40) -ForegroundColor Gray
    Show-VisualLoad -Message "Preparing $label..."
    
    try { 
        # Simulated Progress Bar for Download
        Write-Progress -Activity "Downloading Payload" -Status "Connecting to Server..." -PercentComplete 30
        $content = Invoke-RestMethod $url
        Write-Progress -Activity "Downloading Payload" -Status "Writing to Disk..." -PercentComplete 80
        Set-Content -Path $cmdPath -Value $content -Encoding ASCII 
        Write-Progress -Activity "Downloading Payload" -Completed
    } catch {
        Write-Host "Error: Could not reach the script server." -ForegroundColor Red
        return
    }

    if (Test-Path $cmdPath) {
        Write-Host ">>> EXECUTING MODULE: $label" -ForegroundColor Cyan -BackgroundColor DarkBlue
        Start-Process -FilePath $cmdExe -ArgumentList "/c `"$cmdPath`"" -Verb RunAs -Wait
        Remove-Item -Path $cmdPath -Force
        Write-Host "Successfully Processed: $label" -ForegroundColor Green
    }
    Write-Host ("=" * 40) -ForegroundColor Gray
}

# ---------------- MAIN MENU LOOP ----------------
while ($true) {
      Write-Host "Ready to proceed. Input your choices below:`n" -ForegroundColor Yellow
    $menu = @(
        "0. Exit", "1. Open CMD", "2. Run Runner", "3. Fix Printer RPC(0x0000011b)",
        "4. Script 2", "5. Script 3", "6. Script 4", "7. Script 5",
        "8. Script 6", "9. Script 7", "10. Script 8"
    )

    for ($i = 0; $i -lt $menu.Count; $i += 4) {
        $line = ""
        for ($j = 0; $j -lt 4; $j++) {
            if ($i + $j -lt $menu.Count) { $line += "{0,-20}" -f $menu[$i + $j] }
        }
        Write-Host $line -ForegroundColor White
    }

   Write-Host "`nChoice(s):- " -ForegroundColor Yellow -NoNewline
$inputChoice = Read-Host
    if ($inputChoice -eq "0") { exit }

    $choices = $inputChoice.Split(',').Trim()

    foreach ($choice in $choices) {
        if ($choice -eq "1") {
            Start-Process -FilePath $cmdExe -Verb RunAs
        }
        elseif ($urls.ContainsKey($choice)) {
            DownloadAndRun -url $urls[$choice] -label "Script $choice"
        }
        else {
            Write-Host "Invalid choice: $choice" -ForegroundColor Red
        }
    }
}
