# ===============================
# 1. CORE SYSTEM INFO (SAFE)
# ===============================

$sysInfo  = Get-CimInstance Win32_ComputerSystem
$osInfo   = Get-CimInstance Win32_OperatingSystem
$biosInfo = Get-CimInstance Win32_BIOS
$cpuInfo  = Get-CimInstance Win32_Processor

$driveInfo = Get-PhysicalDisk -ErrorAction SilentlyContinue |
    Select-Object MediaType,
    @{Name="SizeGB";Expression={[math]::Round($_.Size / 1GB,2)}}

$bitlocker = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue

# ===============================
# 2. SECURITY / VIRTUALIZATION
# ===============================

$vbsStatus = try {
    (Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard `
        -ClassName MSFT_DeviceGuard).VirtualizationBasedSecurityStatus
} catch {
    "Not Supported"
}

$amtStatus = if (Get-Service -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "LMS|jhi" }) {
    "Detected / Running"
} else {
    "Not Detected"
}

# ===============================
# 3. UNIVERSAL BATTERY LOGIC
# ===============================

$batteryPresent = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue

# Default values (desktop-safe)
$designCap  = "N/A"
$fullCap    = "N/A"
$currentCap = "N/A"
$cycleCount = "N/A"
$healthPct  = "N/A"
$voltage    = "N/A"
$discharge  = "N/A"

if ($batteryPresent) {

    $battStatic = Get-CimInstance -Namespace root\wmi `
        -ClassName BatteryStaticData -ErrorAction SilentlyContinue

    $battFull = Get-CimInstance -Namespace root\wmi `
        -ClassName BatteryFullChargedCapacity -ErrorAction SilentlyContinue

    $battStatus = Get-CimInstance -Namespace root\wmi `
        -ClassName BatteryStatus -ErrorAction SilentlyContinue

    $battCycle = Get-CimInstance -Namespace root\wmi `
        -ClassName BatteryCycleCount -ErrorAction SilentlyContinue

    $designCap  = $battStatic.DesignedCapacity
    $fullCap    = $battFull.FullChargedCapacity
    $currentCap = $battStatus.RemainingCapacity
    $cycleCount = if ($battCycle.CycleCount) { $battCycle.CycleCount } else { "Unknown" }
    $voltage    = $battStatus.Voltage
    $discharge  = $battStatus.DischargeRate

    if ($designCap -and $fullCap -gt 0) {
        $healthPct = [math]::Round(($fullCap / $designCap) * 100, 2)
    }
}

# ===============================
# 4. FINAL UNIVERSAL OUTPUT
# ===============================

Write-Host "==== UNIVERSAL SYSTEM INVENTORY ====" -ForegroundColor Green

[PSCustomObject]@{
    # --- Device ---
    "Computer Name"        = $sysInfo.Name
    "Manufacturer"         = $sysInfo.Manufacturer
    "Model"                = $sysInfo.Model
    "Device UUID"          = (Get-CimInstance Win32_ComputerSystemProduct).UUID

    # --- OS ---
    "Windows Edition"      = $osInfo.Caption
    "Version"              = $osInfo.Version
    "Build Number"         = $osInfo.BuildNumber
    "Install Date"         = $osInfo.InstallDate

    # --- Hardware ---
    "CPU"                  = $cpuInfo.Name
    "RAM (GB)"             = [math]::Round($sysInfo.TotalPhysicalMemory / 1GB, 2)
    "BIOS Version"         = $biosInfo.SMBIOSBIOSVersion

    # --- Storage ---
    "Disk Type"            = ($driveInfo.MediaType -join ", ")
    "Disk Size (GB)"       = ($driveInfo.SizeGB -join ", ")

    # --- Security ---
    "BitLocker Status"     = $bitlocker.VolumeStatus
    "BitLocker Protection" = $bitlocker.ProtectionStatus
    "Hyper-V Active"       = if ($osInfo.HypervisorPresent) { "Yes" } else { "No" }
    "VBS Status"           = $vbsStatus
    "Intel AMT"            = $amtStatus

    # --- Battery (Universal) ---
    "Battery Present"      = if ($batteryPresent) { "Yes" } else { "No" }
    "Design Capacity (mWh)"= $designCap
    "Full Capacity (mWh)"  = $fullCap
    "Current Charge (mWh)" = $currentCap
    "Battery Health (%)"   = $healthPct
    "Cycle Count"          = $cycleCount
    "Voltage (mV)"         = $voltage
    "Discharge Rate (mW)"  = $discharge
} | Format-List
Read-Host -Prompt "`nPress Enter"


