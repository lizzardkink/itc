# Collect-SystemMetrics.ps1
# Collects system metrics: RAM usage, process count, and boot time from BootRacer
# Runs directly in VM after boot

param(
    [string]$ConfigName = "baseline",
    [int]$Iteration = 1
)

Write-Host "`n=== System Metrics Collection ===" -ForegroundColor Cyan
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Iteration: $Iteration" -ForegroundColor Yellow
$timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
Write-Host "Timestamp: $timestamp`n" -ForegroundColor Gray

# Setup CSV paths
$dataFolder = "Z:\data\$ConfigName"
$ramCSV = "$dataFolder\ram-startup-$ConfigName.csv"
$processCSV = "$dataFolder\process-count-$ConfigName.csv"
$bootCSV = "$dataFolder\boot-time-$ConfigName.csv"

# Create folder if needed
if (!(Test-Path $dataFolder)) {
    New-Item -Path $dataFolder -ItemType Directory -Force | Out-Null
    Write-Host "Created folder: $dataFolder" -ForegroundColor Green
}

# ============================================================================
# [1/3] BOOT TIME from BootRacer
# ============================================================================
Write-Host "[1/3] Reading Boot Time from BootRacer..." -ForegroundColor Yellow
$bootRacerFile = "C:\Users\Public\Documents\Bootracer.his"

try {
    if (!(Test-Path $bootRacerFile)) {
        Write-Host "  X BootRacer history file not found" -ForegroundColor Red
        Write-Host "    Expected: $bootRacerFile" -ForegroundColor Gray
    } else {
        # Read the file as UTF8 text
        $content = [System.IO.File]::ReadAllText($bootRacerFile, [System.Text.Encoding]::UTF8)
        
        # Split into boot records (each record starts with TimeBootFinishHash)
        $records = $content -split 'TimeBootFinishHash=' | Where-Object { $_ -ne "" }
        
        if ($records.Count -eq 0) {
            Write-Host "  X No boot records found in BootRacer file" -ForegroundColor Red
        } else {
            # Get the most recent record (last one)
            $latestRecord = $records[-1]
            
            # Parse values from the record (integers in seconds)
            $timeLogonScreen = if ($latestRecord -match 'TimeLogonScreen=(\d+)') { [int]$Matches[1] } else { 0 }
            $timeLogonFromService = if ($latestRecord -match 'TimeLogonFromService=(\d+)') { [int]$Matches[1] } else { 0 }
            $timeDesktopVisible = if ($latestRecord -match 'TimeDesktopVisible=(\d+)') { [int]$Matches[1] } else { 0 }
            $timeDesktopReady = if ($latestRecord -match 'TimeDesktopReady=(\d+)') { [int]$Matches[1] } else { 0 }
            $timeLogonTimeOut = if ($latestRecord -match 'TimeLogonTimeOut=(\d+)') { [int]$Matches[1] } else { 0 }
            
            # Get floating point part (milliseconds) for sub-second precision
            $floatingPart = if ($latestRecord -match 'FloatingPartOfDeskTime=(\d+)') { [int]$Matches[1] } else { 0 }
            
            # Calculate actual times with decimal precision
            # FloatingPart is milliseconds, so divide by 1000
            $totalBootTime = $timeDesktopReady + ($floatingPart / 1000.0)
            
            # Format with 2 decimal places
            $timeToLogon = "{0:F2}" -f $timeLogonScreen
            $logonTimeout = "{0:F2}" -f $timeLogonTimeOut
            $logonToDesktop = "{0:F2}" -f ($totalBootTime - $timeLogonScreen)
            $totalBootTimeFormatted = "{0:F2}" -f $totalBootTime
            
            Write-Host "  + Time to Logon: $timeToLogon sec" -ForegroundColor Green
            Write-Host "  + Logon Timeout: $logonTimeout sec" -ForegroundColor Green
            Write-Host "  + Logon to Desktop: $logonToDesktop sec" -ForegroundColor Green
            Write-Host "  + Total Boot Time: $totalBootTimeFormatted sec" -ForegroundColor Green
            
            if (!(Test-Path $bootCSV)) {
                "Iteration,Timestamp,TimeToLogon,LogonTimeout,LogonToDesktop,TotalBootTime,Configuration" | Out-File $bootCSV -Encoding UTF8
            }
            "$Iteration,$timestamp,$timeToLogon,$logonTimeout,$logonToDesktop,$totalBootTimeFormatted,$ConfigName" | Out-File $bootCSV -Append -Encoding UTF8
            Write-Host "  + Boot time data saved to CSV" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "  X Error reading BootRacer: $_" -ForegroundColor Red
}

# ============================================================================
# [2/3] RAM USAGE
# ============================================================================
Write-Host "`n[2/3] Measuring RAM Usage..." -ForegroundColor Yellow
$memData = & "Z:\.archived\Get-MemoryInfo.ps1"
if ($memData -and $memData -match '\|') {
    $parts = $memData -split '\|'
    $totalRAM = $parts[0]
    $usedRAM = $parts[1]
    Write-Host "  + Used RAM: $usedRAM MB / $totalRAM MB" -ForegroundColor Green
} else {
    $totalRAM = $usedRAM = "N/A"
    Write-Host "  X Could not read memory data" -ForegroundColor Red
}

if (!(Test-Path $ramCSV)) {
    "Iteration,Timestamp,UsedMemoryMB,TotalMemoryMB,Configuration" | Out-File $ramCSV -Encoding UTF8
}
"$Iteration,$timestamp,$usedRAM,$totalRAM,$ConfigName" | Out-File $ramCSV -Append -Encoding UTF8

# ============================================================================
# [3/3] PROCESS COUNT
# ============================================================================
Write-Host "`n[3/3] Counting Processes..." -ForegroundColor Yellow
try {
    $processCount = (Get-Process).Count
    Write-Host "  + Process Count: $processCount" -ForegroundColor Green
}
catch {
    $processCount = "N/A"
    Write-Host "  X Error counting processes" -ForegroundColor Red
}

if (!(Test-Path $processCSV)) {
    "Iteration,Timestamp,ProcessCount,Configuration" | Out-File $processCSV -Encoding UTF8
}
"$Iteration,$timestamp,$processCount,$ConfigName" | Out-File $processCSV -Append -Encoding UTF8

Write-Host "`n=== Complete ===" -ForegroundColor Green
Write-Host "Data saved to Z:\data\$ConfigName\`n" -ForegroundColor Gray
