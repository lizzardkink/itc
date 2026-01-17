# Automated-Boot-Cycle-With-BootRacer.ps1
# Automates VM shutdown, restart, and measurements INCLUDING BootRacer boot time
# Created: 2026-01-16

param(
    [string]$ConfigName = "baseline",
    [int]$Iterations = 5
)

$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VMName = "WIN11"
$vmUser = "admin"
$vmPass = "admin"

Write-Host "=== Automated Boot Cycle Test (with BootRacer) ===" -ForegroundColor Cyan
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Iterations: $Iterations`n" -ForegroundColor Yellow

$csvPathProcess = "C:\VMShare\data\$ConfigName\process-count-$ConfigName.csv"
$csvPathRAM = "C:\VMShare\data\$ConfigName\ram-startup-$ConfigName.csv"
$csvPathBoot = "C:\VMShare\data\$ConfigName\boot-time-$ConfigName.csv"

# Create CSVs with headers if they don't exist
if (-not (Test-Path $csvPathProcess)) {
    "Iteration,Timestamp,ProcessCount,Configuration" | Out-File -FilePath $csvPathProcess -Encoding UTF8
}
if (-not (Test-Path $csvPathRAM)) {
    "Iteration,Timestamp,TotalMB,UsedMB,FreeMB,UsedPercent,Configuration" | Out-File -FilePath $csvPathRAM -Encoding UTF8
}
if (-not (Test-Path $csvPathBoot)) {
    "Iteration,Timestamp,TimeToLogon,LogonTimeout,TimeDesktopReady,TotalBootTime,Configuration" | Out-File -FilePath $csvPathBoot -Encoding UTF8
}

function Wait-ForVMState {
    param([string]$TargetState, [int]$TimeoutSeconds = 120)
    
    $elapsed = 0
    while ($elapsed -lt $TimeoutSeconds) {
        $state = & $VBoxManage showvminfo $VMName --machinereadable | Select-String "VMState=" | ForEach-Object { $_ -replace 'VMState="([^"]+)"', '$1' }
        
        if ($state -like "*$TargetState*") {
            return $true
        }
        
        Start-Sleep -Seconds 2
        $elapsed += 2
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
    
    return $false
}

function Wait-ForGuestControl {
    param([int]$TimeoutSeconds = 180)
    
    Write-Host "  Waiting for VM guest control to be ready..." -ForegroundColor Yellow
    $elapsed = 0
    
    while ($elapsed -lt $TimeoutSeconds) {
        try {
            $result = & $VBoxManage guestcontrol $VMName --username $vmUser --password $vmPass run --exe "C:\Windows\System32\cmd.exe" -- cmd.exe /c "echo ready" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  Guest control ready!" -ForegroundColor Green
                return $true
            }
        } catch {
            # Connection not ready yet
        }
        
        Start-Sleep -Seconds 3
        $elapsed += 3
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
    
    Write-Host "  Guest control timeout" -ForegroundColor Red
    return $false
}

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "`n=== Iteration $i of $Iterations ===" -ForegroundColor Cyan
    Write-Host ""
    
    if ($i -eq 1) {
        # First iteration: check if we should use running VM or force reboot
        $vmState = & $VBoxManage showvminfo $VMName --machinereadable | Select-String "^VMState=" | ForEach-Object { $_.Line.Split('=')[1].Trim('"') }
        
        if ($vmState -eq "running" -and $Iterations -gt 1) {
            # If running multiple iterations, use current state for first iteration
            Write-Host "  Using already-running VM for first iteration" -ForegroundColor Yellow
        } elseif ($vmState -eq "running") {
            # Single iteration: force reboot to get fresh boot measurement
            Write-Host "  Single iteration test - forcing VM reboot for accurate measurement" -ForegroundColor Yellow
            
            # Shutdown VM
            Write-Host "  Shutting down VM..." -ForegroundColor Yellow
            & $VBoxManage controlvm $VMName acpipowerbutton | Out-Null
            
            Write-Host "  Waiting for VM to power off" -ForegroundColor Gray -NoNewline
            if (Wait-ForVMState -TargetState "poweroff" -TimeoutSeconds 60) {
                Write-Host " ✓" -ForegroundColor Green
            } else {
                Write-Host " ⚠ Forcing power off" -ForegroundColor Yellow
                & $VBoxManage controlvm $VMName poweroff | Out-Null
                Start-Sleep -Seconds 5
            }
            
            Write-Host "  Waiting before restart..." -ForegroundColor Gray
            Start-Sleep -Seconds 5
            
            # Start VM
            Write-Host "  Starting VM (GUI mode)..." -ForegroundColor Yellow
            & $VBoxManage startvm $VMName --type gui | Out-Null
            
            Write-Host "  Waiting for VM to boot" -ForegroundColor Gray -NoNewline
            if (Wait-ForVMState -TargetState "running" -TimeoutSeconds 120) {
                Write-Host " ✓" -ForegroundColor Green
            } else {
                Write-Host " ✗ Timeout" -ForegroundColor Red
                continue
            }
            
            # Wait for guest control
            if (-not (Wait-ForGuestControl -TimeoutSeconds 180)) {
                Write-Host "  Skipping iteration - guest control not ready" -ForegroundColor Red
                continue
            }
        } else {
            # VM not running - start it
            Write-Host "  Starting VM..." -ForegroundColor Yellow
            & $VBoxManage startvm $VMName --type gui | Out-Null
            
            if (-not (Wait-ForVMState -TargetState "running" -TimeoutSeconds 120)) {
                Write-Host "  Failed to start VM" -ForegroundColor Red
                continue
            }
            
            if (-not (Wait-ForGuestControl -TimeoutSeconds 180)) {
                Write-Host "  Guest control not ready" -ForegroundColor Red
                continue
            }
        }
    } else {
        # Subsequent iterations: always reboot
        # Shutdown VM (graceful)
        Write-Host "  Shutting down VM..." -ForegroundColor Yellow
        & $VBoxManage controlvm $VMName acpipowerbutton | Out-Null
        
        Write-Host "  Waiting for VM to power off" -ForegroundColor Gray -NoNewline
        if (Wait-ForVMState -TargetState "poweroff" -TimeoutSeconds 60) {
            Write-Host " ✓" -ForegroundColor Green
        } else {
            Write-Host " ⚠ Forcing power off" -ForegroundColor Yellow
            & $VBoxManage controlvm $VMName poweroff | Out-Null
            Start-Sleep -Seconds 5
        }
        
        # Wait a bit before starting
        Write-Host "  Waiting before restart..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
        
        # Start VM
        Write-Host "  Starting VM (GUI mode)..." -ForegroundColor Yellow
        & $VBoxManage startvm $VMName --type gui | Out-Null
        
        Write-Host "  Waiting for VM to boot" -ForegroundColor Gray -NoNewline
        if (Wait-ForVMState -TargetState "running" -TimeoutSeconds 30) {
            Write-Host " ✓" -ForegroundColor Green
        } else {
            Write-Host " ✗ Failed" -ForegroundColor Red
            continue
        }
        
        # Wait for guest control
        if (-not (Wait-ForGuestControl -TimeoutSeconds 180)) {
            Write-Host "  ⚠ Skipping this iteration" -ForegroundColor Yellow
            continue
        }
    }
    
    # Wait for system to stabilize
    Write-Host "  Waiting for system to stabilize (30s)..." -ForegroundColor Gray
    Start-Sleep -Seconds 30
    
    # Collect measurements
    Write-Host "  Collecting measurements..." -ForegroundColor Yellow
    
    try {
        $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        $processCount = & $VBoxManage guestcontrol $VMName --username $vmUser --password $vmPass run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe -Command "(Get-Process).Count" 2>&1
        $memData = & $VBoxManage guestcontrol $VMName --username $vmUser --password $vmPass run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe -ExecutionPolicy Bypass -File "Z:\Get-MemoryInfo.ps1" 2>&1
        
        # Get TOTAL boot time from BootRacer .his file (most recent entry)
        $bootData = & $VBoxManage guestcontrol $VMName --username $vmUser --password $vmPass run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe -ExecutionPolicy Bypass -File "Z:\Get-LatestBootTime.ps1" 2>&1
        
        $memParts = $memData -split '\|'
        $totalMB = $memParts[0]
        $usedMB = $memParts[1]
        $freeMB = $memParts[2]
        $usedPercent = $memParts[3]
        
        # Parse boot time components
        if ($bootData -ne 'N/A' -and $bootData -match '\|') {
            $bootParts = $bootData -split '\|'
            $timeToLogon = $bootParts[0]
            $logonTimeout = $bootParts[1]
            $logonToDesktop = $bootParts[2]
            $totalBootTime = $bootParts[3]
        } else {
            $timeToLogon = "N/A"
            $logonTimeout = "N/A"
            $logonToDesktop = "N/A"
            $totalBootTime = "N/A"
        }
        
        Write-Host "    TOTAL Boot Time: $totalBootTime seconds" -ForegroundColor Green
        Write-Host "      (To Logon: ${timeToLogon}s | Timeout: ${logonTimeout}s | Desktop Ready: ${logonToDesktop}s)" -ForegroundColor Gray
        Write-Host "    Process Count: $processCount" -ForegroundColor Cyan
        Write-Host "    RAM Used: $usedMB MB ($usedPercent%)" -ForegroundColor Cyan
        
        # Save to CSVs
        "$i,$timestamp,$processCount,$ConfigName" | Out-File -FilePath $csvPathProcess -Append -Encoding UTF8
        "$i,$timestamp,$totalMB,$usedMB,$freeMB,$usedPercent,$ConfigName" | Out-File -FilePath $csvPathRAM -Append -Encoding UTF8
        "$i,$timestamp,$timeToLogon,$logonTimeout,$logonToDesktop,$totalBootTime,$ConfigName" | Out-File -FilePath $csvPathBoot -Append -Encoding UTF8
        
        Write-Host "  ✓ Data saved" -ForegroundColor Green
        
    } catch {
        Write-Host "  ✗ Error collecting data: $_" -ForegroundColor Red
    }
}

Write-Host "`n=== Boot Cycle Test Complete ===" -ForegroundColor Green

Write-Host "`nBoot Time Results:" -ForegroundColor Yellow
Import-Csv $csvPathBoot | Format-Table -AutoSize

Write-Host "`nProcess Count Results:" -ForegroundColor Yellow
Import-Csv $csvPathProcess | Format-Table -AutoSize

Write-Host "`nRAM Usage Results:" -ForegroundColor Yellow
Import-Csv $csvPathRAM | Format-Table -AutoSize

