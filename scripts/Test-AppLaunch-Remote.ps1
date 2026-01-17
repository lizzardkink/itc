# Test-AppLaunch-Remote.ps1
# App Launch Performance Test
# UPDATED: 2026-01-17 - Now uses VBoxManage guest control

param(
    [int]$Iterations = 5,
    [string]$ConfigName = "baseline"
)

$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VMName = "WIN11"
$vmUser = "admin"
$vmPass = "admin"

Write-Host "=== App Launch Performance Test ===" -ForegroundColor Cyan
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Iterations: $Iterations" -ForegroundColor Yellow
Write-Host "Apps: 25 Calc + 25 Notepad + 25 Paint = 75 total per iteration`n" -ForegroundColor Gray

$csvPath = "C:\VMShare\data\$ConfigName\app-launch-$ConfigName.csv"

# Create data directory if needed
$dataDir = Split-Path $csvPath -Parent
if (-not (Test-Path $dataDir)) {
    New-Item -Path $dataDir -ItemType Directory -Force | Out-Null
}

# Create CSV with header if it doesn't exist
if (-not (Test-Path $csvPath)) {
    "Index,Timestamp,TimeMs,TimeSeconds,Configuration" | Out-File -FilePath $csvPath -Encoding UTF8
}

# Get starting index
$index = 1
if (Test-Path $csvPath) {
    $content = Get-Content $csvPath -ErrorAction SilentlyContinue
    if ($content -and $content.Count -gt 1) {
        $lastLine = if ($content -is [array]) { $content[-1] } else { $content }
        if ($lastLine -match "^(\d+),") {
            $index = [int]$matches[1] + 1
        }
    }
}

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "Iteration $i of $Iterations (Index: $index)" -ForegroundColor Cyan
    
    try {
        # Run app launch test on VM
        $result = & $VBoxManage guestcontrol $VMName --username $vmUser --password $vmPass run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe -ExecutionPolicy Bypass -File "Z:\VM-Helper-App-Launch.ps1" 2>&1
        
        if ($LASTEXITCODE -eq 0 -and $result -match '\|') {
            $parts = ($result | Select-String -Pattern '\d+\.\d+\|\d+\.\d+').Matches[0].Value -split '\|'
            $timeMs = $parts[0]
            $timeSeconds = $parts[1]
            
            $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
            
            Write-Host "  Time: $timeSeconds seconds ($timeMs ms)" -ForegroundColor Green
            
            # Save to CSV
            "$index,$timestamp,$timeMs,$timeSeconds,$ConfigName" | Out-File -FilePath $csvPath -Append -Encoding UTF8
            
        } else {
            Write-Host "  Error: Test failed or returned invalid data" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
    
    $index++
    Write-Host ""
}

Write-Host "=== App Launch Test Complete ===" -ForegroundColor Cyan
Write-Host "Results saved to: $csvPath`n" -ForegroundColor Green

# Display summary
Write-Host "Summary:" -ForegroundColor Yellow
Import-Csv $csvPath | Select-Object -Last 10 | Format-Table -AutoSize
