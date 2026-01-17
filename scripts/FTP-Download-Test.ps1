# FTP-Download-Test.ps1
# Measures FTP download performance from DIGI Storage
# UPDATED: 2026-01-17 - Now uses VBoxManage guest control

param(
    [string]$ConfigName = "baseline",
    [int]$Iterations = 5
)

$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VMName = "WIN11"
$vmUser = "admin"
$vmPass = "admin"

Write-Host "=== FTP Download Test ===" -ForegroundColor Cyan
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Iterations: $Iterations`n" -ForegroundColor Yellow

$csvPath = "C:\VMShare\data\$ConfigName\ftp-download-$ConfigName.csv"

# Create data directory if needed
$dataDir = Split-Path $csvPath -Parent
if (-not (Test-Path $dataDir)) {
    New-Item -Path $dataDir -ItemType Directory -Force | Out-Null
}

# Create CSV with header if it doesn't exist
if (-not (Test-Path $csvPath)) {
    "Iteration,Timestamp,FileSizeMB,DownloadTimeSeconds,SpeedMBps,Configuration" | Out-File -FilePath $csvPath -Encoding UTF8
}

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "Iteration $i of $Iterations" -ForegroundColor Cyan
    
    try {
        # Run FTP download test on VM
        $result = & $VBoxManage guestcontrol $VMName --username $vmUser --password $vmPass run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe -ExecutionPolicy Bypass -File "Z:\VM-Helper-FTP-Download.ps1" -Iteration $i 2>&1
        
        if ($LASTEXITCODE -eq 0 -and $result -match '\|') {
            $parts = ($result | Select-String -Pattern '\d+\.\d+\|\d+\.\d+\|\d+\.\d+').Matches[0].Value -split '\|'
            $fileSizeMB = $parts[0]
            $downloadTime = $parts[1]
            $speedMBps = $parts[2]
            
            $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            
            Write-Host "  File Size: $fileSizeMB MB" -ForegroundColor White
            Write-Host "  Download Time: $downloadTime seconds" -ForegroundColor White
            Write-Host "  Speed: $speedMBps MB/s" -ForegroundColor Green
            
            # Save to CSV
            "$i,$timestamp,$fileSizeMB,$downloadTime,$speedMBps,$ConfigName" | Out-File -FilePath $csvPath -Append -Encoding UTF8
            
        } else {
            Write-Host "  Error: Test failed or returned invalid data" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "=== FTP Test Complete ===" -ForegroundColor Cyan
Write-Host "Results saved to: $csvPath`n" -ForegroundColor Green

# Display summary
Write-Host "Summary:" -ForegroundColor Yellow
Import-Csv $csvPath | Format-Table -AutoSize
