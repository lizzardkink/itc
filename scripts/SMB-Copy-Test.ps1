# SMB-Copy-Test.ps1
# Measures SMB network copy performance from QNAP NAS to VM Desktop
# UPDATED: 2026-01-17 - Now uses VBoxManage guest control

param(
    [string]$ConfigName = "baseline",
    [int]$Iterations = 5
)

$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VMName = "WIN11"
$vmUser = "admin"
$vmPass = "admin"

Write-Host "=== SMB Network Copy Test ===" -ForegroundColor Cyan
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Iterations: $Iterations`n" -ForegroundColor Yellow

$csvPath = "C:\VMShare\data\$ConfigName\smb-copy-$ConfigName.csv"

# Create data directory if needed
$dataDir = Split-Path $csvPath -Parent
if (-not (Test-Path $dataDir)) {
    New-Item -Path $dataDir -ItemType Directory -Force | Out-Null
}

# Create CSV with header if it doesn't exist
if (-not (Test-Path $csvPath)) {
    "Iteration,Timestamp,SourceSizeGB,CopyTimeSeconds,SpeedMBps,Configuration" | Out-File -FilePath $csvPath -Encoding UTF8
}

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "Iteration $i of $Iterations" -ForegroundColor Cyan
    
    try {
        # Run SMB copy test on VM with longer timeout
        $result = & $VBoxManage guestcontrol $VMName --username $vmUser --password $vmPass run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" --wait-stdout --wait-stderr -- powershell.exe -ExecutionPolicy Bypass -File "Z:\VM-Helper-SMB-Copy.ps1" -Iteration $i 2>&1
        
        if ($LASTEXITCODE -eq 0 -and $result -match '[\d\.]+\|[\d\.]+\|[\d\.]+') {
            # Extract the last line with the pipe-delimited result
            $resultLine = ($result -split "`n" | Where-Object { $_ -match '[\d\.]+\|[\d\.]+\|[\d\.]+\s*$' }) | Select-Object -Last 1
            
            if ($resultLine) {
                $parts = $resultLine.Trim() -split '\|'
                $sourceSizeGB = $parts[0]
                $copyTime = $parts[1]
                $speedMBps = $parts[2]
                
                $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
                
                Write-Host "  Source Size: $sourceSizeGB GB" -ForegroundColor White
                Write-Host "  Copy Time: $copyTime seconds" -ForegroundColor White
                Write-Host "  Speed: $speedMBps MB/s" -ForegroundColor Green
                
                # Save to CSV
                "$i,$timestamp,$sourceSizeGB,$copyTime,$speedMBps,$ConfigName" | Out-File -FilePath $csvPath -Append -Encoding UTF8
            } else {
                Write-Host "  Error: Could not parse result" -ForegroundColor Red
                Write-Host "  Result text: $result" -ForegroundColor Gray
            }
        } else {
            Write-Host "  Error: Test failed or returned invalid data" -ForegroundColor Red
            Write-Host "  Exit code: $LASTEXITCODE" -ForegroundColor Gray
            Write-Host "  Full output:" -ForegroundColor Yellow
            $result | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
        }
        
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "=== SMB Test Complete ===" -ForegroundColor Cyan
Write-Host "Results saved to: $csvPath`n" -ForegroundColor Green

# Display summary
Write-Host "Summary:" -ForegroundColor Yellow
Import-Csv $csvPath | Format-Table -AutoSize
