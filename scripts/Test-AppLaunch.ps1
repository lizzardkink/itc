# Test-AppLaunch.ps1
# App launch performance test - runs directly in VM
# Launches 30 apps (10 calc, 10 notepad, 10 paint) in random order
# Runs 5 iterations with 10 second delay between iterations
# Measures time and appends to CSV

param(
    [string]$ConfigName = "baseline",
    [int]$Iterations = 5,
    [int]$CalcCount = 10,
    [int]$NotepadCount = 10,
    [int]$PaintCount = 10,
    [int]$DelaySeconds = 10
)

Write-Host "`n=== App Launch Performance Test ===" -ForegroundColor Cyan
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Iterations: $Iterations" -ForegroundColor Yellow
Write-Host "Apps per iteration: $CalcCount Calc + $NotepadCount Notepad + $PaintCount Paint = $($CalcCount + $NotepadCount + $PaintCount) total" -ForegroundColor Gray
Write-Host "Delay between iterations: $DelaySeconds seconds`n" -ForegroundColor Gray

# Setup CSV path
$dataFolder = "Z:\data\$ConfigName"
$appLaunchCSV = "$dataFolder\app-launch-$ConfigName.csv"

# Create folder if needed
if (!(Test-Path $dataFolder)) {
    New-Item -Path $dataFolder -ItemType Directory -Force | Out-Null
}

# Create CSV header if needed
if (!(Test-Path $appLaunchCSV)) {
    "Iteration,Timestamp,TimeMs,TimeSeconds,Configuration" | Out-File $appLaunchCSV -Encoding UTF8
}

# ============================================================================
# RUN ITERATIONS
# ============================================================================

for ($iteration = 1; $iteration -le $Iterations; $iteration++) {
    Write-Host "=== ITERATION $iteration of $Iterations ===" -ForegroundColor Cyan
    $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    
    Write-Host "Preparing app list..." -ForegroundColor Yellow
    
    $startTime = Get-Date
    
    try {
        # Create array of all apps to launch
        $appsToLaunch = @()
        
        # Add calculators
        for ($i = 1; $i -le $CalcCount; $i++) {
            $appsToLaunch += @{ App = "calc.exe"; Name = "Calculator" }
        }
        
        # Add notepads
        for ($i = 1; $i -le $NotepadCount; $i++) {
            $appsToLaunch += @{ App = "notepad.exe"; Name = "Notepad" }
        }
        
        # Add paints
        for ($i = 1; $i -le $PaintCount; $i++) {
            $appsToLaunch += @{ App = "mspaint.exe"; Name = "Paint" }
        }
        
        # Randomize the order
        $randomizedApps = $appsToLaunch | Sort-Object { Get-Random }
        
        Write-Host "Launching $($appsToLaunch.Count) apps in random order..." -ForegroundColor Yellow
        $launched = 0
        foreach ($appInfo in $randomizedApps) {
            Start-Process $appInfo.App -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 50
            $launched++
            
            # Progress indicator every 10 apps
            if ($launched % 10 -eq 0) {
                Write-Host "  Launched $launched/$($appsToLaunch.Count)..." -ForegroundColor Gray
            }
        }
        
        # Wait for all apps to fully launch
        Start-Sleep -Seconds 2
        
        $endTime = Get-Date
        $totalTimeMs = ($endTime - $startTime).TotalMilliseconds
        # Format to 2 decimal places per constitution
        $totalTimeSeconds = "{0:F2}" -f ($totalTimeMs / 1000)
        
        Write-Host "  + Launch Time: $totalTimeSeconds seconds" -ForegroundColor Green
        
        # Cleanup - kill all launched apps
        Write-Host "Cleaning up..." -ForegroundColor Yellow
        Get-Process | Where-Object { $_.ProcessName -match '^(Calculator|CalculatorApp|notepad|mspaint)$' } | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        Get-Process | Where-Object { $_.ProcessName -match '^(Calculator|CalculatorApp|notepad|mspaint)$' } | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "  + Cleanup complete" -ForegroundColor Green
        
        # Write to CSV
        "$iteration,$timestamp,$totalTimeMs,$totalTimeSeconds,$ConfigName" | Out-File $appLaunchCSV -Append -Encoding UTF8
        
        Write-Host "  + Data saved to CSV" -ForegroundColor Green
        
        # Delay before next iteration (except after last one)
        if ($iteration -lt $Iterations) {
            Write-Host "`nWaiting $DelaySeconds seconds before next iteration..." -ForegroundColor Yellow
            Start-Sleep -Seconds $DelaySeconds
            Write-Host ""
        }
        
    } catch {
        Write-Host "`nX Error during iteration $iteration : $_" -ForegroundColor Red
        # Try cleanup even on error
        Get-Process | Where-Object { $_.ProcessName -match '^(Calculator|CalculatorApp|notepad|mspaint)$' } | Stop-Process -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n=== All Iterations Complete ===" -ForegroundColor Green
Write-Host "Results saved to: $appLaunchCSV`n" -ForegroundColor Gray

