# Run-All-Tests.ps1
# Master pipeline script - runs all performance tests in sequence
# Executes inside the VM for a specific configuration

param(
    [string]$ConfigName = "baseline",
    [switch]$SkipSystemMetrics,
    [switch]$SkipAppLaunch,
    [switch]$SkipSMB,
    [switch]$SkipFTP
)

$scriptPath = "Z:\tests"
$startTime = Get-Date

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "          PERFORMANCE TEST PIPELINE                            " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "`nConfiguration: $ConfigName" -ForegroundColor Yellow
Write-Host "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Track test results
$results = @{
    SystemMetrics = "Skipped"
    AppLaunch = "Skipped"
    SMB = "Skipped"
    FTP = "Skipped"
}

# TEST 1: System Metrics (RAM + Process Count)
# ============================================================================
if (!$SkipSystemMetrics) {
    Write-Host "`n=== TEST 1/4: System Metrics ===" -ForegroundColor Cyan
    Write-Host "Collecting RAM usage and process count..." -ForegroundColor Yellow
    
    try {
        & "$scriptPath\Collect-SystemMetrics.ps1" -ConfigName $ConfigName -Iteration 1
        if ($LASTEXITCODE -eq 0 -or !$LASTEXITCODE) {
            $results.SystemMetrics = "Success"
            Write-Host "`n+ System metrics collected successfully" -ForegroundColor Green
        } else {
            $results.SystemMetrics = "Failed"
            Write-Host "`nX System metrics test failed (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        }
    } catch {
        $results.SystemMetrics = "Failed"
        Write-Host "`nX System metrics test failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "`n=== TEST 1/4: System Metrics === SKIPPED" -ForegroundColor Gray
}

# ============================================================================
# TEST 2: App Launch Performance (5 iterations)
# ============================================================================
if (!$SkipAppLaunch) {
    Write-Host "`n=== TEST 2/4: App Launch Performance ===" -ForegroundColor Cyan
    Write-Host "Launching 30 apps across 5 iterations..." -ForegroundColor Yellow
    Write-Host "This will take approximately 3-5 minutes..." -ForegroundColor Gray
    
    try {
        & "$scriptPath\Test-AppLaunch.ps1" -ConfigName $ConfigName
        if ($LASTEXITCODE -eq 0 -or !$LASTEXITCODE) {
            $results.AppLaunch = "Success"
            Write-Host "`n+ App launch test completed successfully" -ForegroundColor Green
        } else {
            $results.AppLaunch = "Failed"
            Write-Host "`nX App launch test failed (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        }
    } catch {
        $results.AppLaunch = "Failed"
        Write-Host "`nX App launch test failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "`n=== TEST 2/4: App Launch Performance === SKIPPED" -ForegroundColor Gray
}

# ============================================================================
# TEST 3: SMB Network Copy (5 iterations)
# ============================================================================
if (!$SkipSMB) {
    Write-Host "`n=== TEST 3/4: SMB Network Copy ===" -ForegroundColor Cyan
    Write-Host "Copying 1GB folder from NAS via SMB..." -ForegroundColor Yellow
    Write-Host "This will take approximately 2-5 minutes depending on network speed..." -ForegroundColor Gray
    
    try {
        & "$scriptPath\Test-SMB.ps1" -ConfigName $ConfigName
        if ($LASTEXITCODE -eq 0 -or !$LASTEXITCODE) {
            $results.SMB = "Success"
            Write-Host "`n+ SMB copy test completed successfully" -ForegroundColor Green
        } else {
            $results.SMB = "Failed"
            Write-Host "`nX SMB copy test failed (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        }
    } catch {
        $results.SMB = "Failed"
        Write-Host "`nX SMB copy test failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "`n=== TEST 3/4: SMB Network Copy === SKIPPED" -ForegroundColor Gray
}

# ============================================================================
# TEST 4: FTP Download (5 iterations)
# ============================================================================
if (!$SkipFTP) {
    Write-Host "`n=== TEST 4/4: FTP Download ===" -ForegroundColor Cyan
    Write-Host "Downloading 100MB file from DIGI Storage..." -ForegroundColor Yellow
    Write-Host "This will take approximately 2-4 minutes depending on internet speed..." -ForegroundColor Gray
    
    try {
        & "$scriptPath\Test-FTP.ps1" -ConfigName $ConfigName
        if ($LASTEXITCODE -eq 0 -or !$LASTEXITCODE) {
            $results.FTP = "Success"
            Write-Host "`n+ FTP download test completed successfully" -ForegroundColor Green
        } else {
            $results.FTP = "Failed"
            Write-Host "`nX FTP download test failed (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        }
    } catch {
        $results.FTP = "Failed"
        Write-Host "`nX FTP download test failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "`n=== TEST 4/4: FTP Download === SKIPPED" -ForegroundColor Gray
}

# ============================================================================
# SUMMARY
# ============================================================================
$endTime = Get-Date
$totalTime = ($endTime - $startTime).TotalMinutes

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "          TEST PIPELINE COMPLETE                               " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "`nConfiguration: $ConfigName" -ForegroundColor Yellow
Write-Host "Total Runtime: $([math]::Round($totalTime, 2)) minutes" -ForegroundColor Gray
Write-Host "`nTest Results:" -ForegroundColor Yellow

foreach ($test in $results.Keys | Sort-Object) {
    $status = $results[$test]
    $color = switch ($status) {
        "Success" { "Green" }
        "Failed" { "Red" }
        "Skipped" { "Gray" }
    }
    $symbol = switch ($status) {
        "Success" { "+" }
        "Failed" { "X" }
        "Skipped" { "-" }
    }
    Write-Host "  $symbol $test : $status" -ForegroundColor $color
}

Write-Host "`nData Location:" -ForegroundColor Yellow
Write-Host "  Z:\data\$ConfigName\" -ForegroundColor Gray

Write-Host ""

# Exit with error if any test failed
$failedTests = ($results.Values | Where-Object { $_ -eq "Failed" }).Count
if ($failedTests -gt 0) {
    Write-Host "Pipeline completed with $failedTests failed test(s)" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All tests completed successfully!" -ForegroundColor Green
    exit 0
}
