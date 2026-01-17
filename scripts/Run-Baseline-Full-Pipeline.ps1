param(
    [string]$ConfigName = "baseline"
)

$ErrorActionPreference = "Continue"

# Define tests
$tests = @(
    @{
        Name = "Boot Cycle Test"
        Script = "Automated-Boot-Cycle-With-BootRacer.ps1"
        Criteria = "A, B, C"
        Iterations = 5
        EstimatedMinutes = 10
    },
    @{
        Name = "App Launch Performance"
        Script = "Test-AppLaunch-Remote.ps1"
        Criteria = "D"
        Iterations = 5
        EstimatedMinutes = 5
    },
    @{
        Name = "SMB Network Copy"
        Script = "SMB-Copy-Test.ps1"
        Criteria = "E"
        Iterations = 5
        EstimatedMinutes = 5
    },
    @{
        Name = "FTP Download"
        Script = "FTP-Download-Test.ps1"
        Criteria = "F"
        Iterations = 5
        EstimatedMinutes = 5
    }
)

$totalTests = $tests.Count
$totalEstimatedMinutes = ($tests | Measure-Object -Property EstimatedMinutes -Sum).Sum

# Display header
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "    BASELINE FULL TESTING PIPELINE - 5 ITERATIONS" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Total Tests: $totalTests" -ForegroundColor Yellow
Write-Host "Total Iterations: 25 (5 per test)" -ForegroundColor Yellow
Write-Host "Estimated Time: approximately $totalEstimatedMinutes minutes" -ForegroundColor Yellow
Write-Host ""

# Display test plan
Write-Host "Test Plan:" -ForegroundColor Cyan
for ($i = 0; $i -lt $tests.Count; $i++) {
    $test = $tests[$i]
    Write-Host "  $($i+1). $($test.Name)" -ForegroundColor White
    Write-Host "     Criteria: $($test.Criteria) | Iterations: $($test.Iterations)" -ForegroundColor Gray
}
Write-Host ""

# Confirm start
Write-Host "Press Enter to start testing, or Ctrl+C to cancel..." -ForegroundColor Yellow
Read-Host

# Start pipeline
$pipelineStart = Get-Date
$results = @()

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "Pipeline started at: $($pipelineStart.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# Execute each test
$testNumber = 0
foreach ($test in $tests) {
    $testNumber++
    
    Write-Host ""
    Write-Host "---------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "TEST $testNumber of $totalTests : $($test.Name)" -ForegroundColor Yellow
    Write-Host "Criteria: $($test.Criteria) | Iterations: $($test.Iterations)" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    
    # Progress
    $percentComplete = [math]::Round(($testNumber - 1) / $totalTests * 100)
    $progressBar = "#" * [math]::Floor($percentComplete / 5)
    $emptyBar = "-" * (20 - [math]::Floor($percentComplete / 5))
    Write-Host "  Overall Progress: [$progressBar$emptyBar] $percentComplete%" -ForegroundColor Yellow
    Write-Host ""
    
    $testStart = Get-Date
    
    try {
        $scriptPath = Join-Path $PSScriptRoot $test.Script
        
        if (-not (Test-Path $scriptPath)) {
            Write-Host "  ERROR: Script not found: $scriptPath" -ForegroundColor Red
            $results += @{
                Test = $test.Name
                Status = "FAILED"
                Error = "Script not found"
                Duration = "N/A"
            }
            continue
        }
        
        Write-Host "  Executing: $($test.Script)" -ForegroundColor Gray
        Write-Host "  Please wait..." -ForegroundColor Gray
        Write-Host ""
        
        & $scriptPath -ConfigName $ConfigName -Iterations $test.Iterations
        
        $testEnd = Get-Date
        $testDuration = $testEnd - $testStart
        
        Write-Host ""
        Write-Host "  Test completed in $($testDuration.TotalMinutes.ToString('F2')) minutes" -ForegroundColor Green
        
        $results += @{
            Test = $test.Name
            Status = "SUCCESS"
            Duration = $testDuration.TotalMinutes.ToString('F2')
            Iterations = $test.Iterations
        }
        
    } catch {
        $testEnd = Get-Date
        $testDuration = $testEnd - $testStart
        
        Write-Host ""
        Write-Host "  Test FAILED after $($testDuration.TotalMinutes.ToString('F2')) minutes" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
        
        $results += @{
            Test = $test.Name
            Status = "FAILED"
            Error = $_.Exception.Message
            Duration = $testDuration.TotalMinutes.ToString('F2')
        }
    }
}

# Final progress
Write-Host ""
Write-Host "  Overall Progress: [####################] 100%" -ForegroundColor Green
Write-Host ""

# End pipeline
$pipelineEnd = Get-Date
$pipelineDuration = $pipelineEnd - $pipelineStart

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Green
Write-Host "PIPELINE COMPLETE!" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Started:  $($pipelineStart.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
Write-Host "Finished: $($pipelineEnd.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
Write-Host "Duration: $($pipelineDuration.Hours)h $($pipelineDuration.Minutes)m $($pipelineDuration.Seconds)s" -ForegroundColor White
Write-Host ""

# Results summary
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

$successCount = ($results | Where-Object { $_.Status -eq "SUCCESS" }).Count
$failCount = ($results | Where-Object { $_.Status -eq "FAILED" }).Count

foreach ($result in $results) {
    $status = if ($result.Status -eq "SUCCESS") { "OK" } else { "FAIL" }
    $color = if ($result.Status -eq "SUCCESS") { "Green" } else { "Red" }
    
    Write-Host "  $status " -ForegroundColor $color -NoNewline
    Write-Host "$($result.Test)" -ForegroundColor White
    Write-Host "    Status: $($result.Status) | Duration: $($result.Duration) min" -ForegroundColor Gray
    
    if ($result.Error) {
        Write-Host "    Error: $($result.Error)" -ForegroundColor Red
    }
    if ($result.Iterations) {
        Write-Host "    Iterations: $($result.Iterations)" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "Total: $successCount passed, $failCount failed" -ForegroundColor $(if($failCount -eq 0){"Green"}else{"Yellow"})
Write-Host ""

# Data location
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "DATA LOCATION" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "CSV Files: C:\VMShare\data\$ConfigName\" -ForegroundColor White
Write-Host ""
Write-Host "Files generated:" -ForegroundColor Yellow
$dataPath = "C:\VMShare\data\$ConfigName"
if (Test-Path $dataPath) {
    Get-ChildItem "$dataPath\*.csv" | ForEach-Object {
        $lineCount = (Get-Content $_.FullName | Measure-Object -Line).Lines - 1
        Write-Host "  * $($_.Name) - $lineCount data rows" -ForegroundColor Gray
    }
} else {
    Write-Host "  Data directory not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# Exit with appropriate code
if ($failCount -eq 0) {
    Write-Host "All tests completed successfully! Ready for next configuration." -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some tests failed. Review errors above." -ForegroundColor Yellow
    exit 1
}