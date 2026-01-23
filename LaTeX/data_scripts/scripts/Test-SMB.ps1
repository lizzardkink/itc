# Test-SMB.ps1
# SMB network copy performance test - runs directly in VM
# Copies 1GB folder from NAS to VM via SMB
# Measures transfer time and appends to CSV

param(
    [string]$ConfigName = "baseline",
    [int]$Iterations = 5,
    [string]$SourcePath = "\\192.168.50.99\Public\Test",
    [string]$DestinationPath = "$env:USERPROFILE\Desktop\SMB",
    [int]$DelaySeconds = 5
)

Write-Host "`n=== SMB Network Copy Test ===" -ForegroundColor Cyan
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Iterations: $Iterations" -ForegroundColor Yellow
Write-Host "Source: $SourcePath" -ForegroundColor Gray
Write-Host "Destination: $DestinationPath" -ForegroundColor Gray
Write-Host "Delay between iterations: $DelaySeconds seconds`n" -ForegroundColor Gray

# Setup CSV path
$dataFolder = "Z:\data\$ConfigName"
$smbCSV = "$dataFolder\smb-copy-$ConfigName.csv"

# Create folder if needed
if (!(Test-Path $dataFolder)) {
    New-Item -Path $dataFolder -ItemType Directory -Force | Out-Null
}

# Create CSV header if needed
if (!(Test-Path $smbCSV)) {
    "Iteration,Timestamp,SourceSizeGB,CopyTimeSeconds,SpeedMBps,Configuration" | Out-File $smbCSV -Encoding UTF8
}

# ============================================================================
# VERIFY SOURCE
# ============================================================================
Write-Host "Verifying source..." -ForegroundColor Yellow
if (!(Test-Path $SourcePath)) {
    Write-Host "X Source path not accessible: $SourcePath" -ForegroundColor Red
    Write-Host "  Make sure NAS is accessible and path is correct" -ForegroundColor Yellow
    exit 1
}

# Get source size
$sourceSize = (Get-ChildItem $SourcePath -Recurse | Measure-Object -Property Length -Sum).Sum
$sourceSizeGB = "{0:F2}" -f ($sourceSize / 1GB)
Write-Host "  + Source size: $sourceSizeGB GB" -ForegroundColor Green

# ============================================================================
# RUN ITERATIONS
# ============================================================================

for ($iteration = 1; $iteration -le $Iterations; $iteration++) {
    Write-Host "`n=== ITERATION $iteration of $Iterations ===" -ForegroundColor Cyan
    $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    
    # Clean destination before copy
    if (Test-Path $DestinationPath) {
        Write-Host "Cleaning destination..." -ForegroundColor Yellow
        Remove-Item $DestinationPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Create destination folder
    New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
    
    Write-Host "Starting copy..." -ForegroundColor Yellow
    $startTime = Get-Date
    
    try {
        # Copy files
        Copy-Item -Path "$SourcePath\*" -Destination $DestinationPath -Recurse -Force
        
        $endTime = Get-Date
        $copyTimeSeconds = "{0:F2}" -f ($endTime - $startTime).TotalSeconds
        
        # Calculate speed in MB/s
        $speedMBps = "{0:F2}" -f (($sourceSize / 1MB) / [double]$copyTimeSeconds)
        
        Write-Host "  + Copy Time: $copyTimeSeconds seconds" -ForegroundColor Green
        Write-Host "  + Speed: $speedMBps MB/s" -ForegroundColor Green
        
        # Write to CSV
        "$iteration,$timestamp,$sourceSizeGB,$copyTimeSeconds,$speedMBps,$ConfigName" | Out-File $smbCSV -Append -Encoding UTF8
        Write-Host "  + Data saved to CSV" -ForegroundColor Green
        
        # Clean up destination
        Write-Host "Cleaning up..." -ForegroundColor Yellow
        Remove-Item $DestinationPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  + Cleanup complete" -ForegroundColor Green
        
        # Delay before next iteration (except after last one)
        if ($iteration -lt $Iterations) {
            Write-Host "`nWaiting $DelaySeconds seconds before next iteration..." -ForegroundColor Yellow
            Start-Sleep -Seconds $DelaySeconds
        }
        
    } catch {
        Write-Host "`nX Error during iteration $iteration : $_" -ForegroundColor Red
        # Try cleanup even on error
        Remove-Item $DestinationPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n=== All Iterations Complete ===" -ForegroundColor Green
Write-Host "Results saved to: $smbCSV`n" -ForegroundColor Gray
