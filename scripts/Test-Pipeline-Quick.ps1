# Test-Pipeline-Quick.ps1
# Quick pipeline test with 1 iteration per test for validation

param(
    [string]$ConfigName = "test"
)

$ErrorActionPreference = "Continue"

# Test configuration (1 iteration each for quick test)
$tests = @(
    @{
        Name = "Boot Cycle (Boot Time + RAM + Process Count)"
        Script = "Automated-Boot-Cycle-With-BootRacer.ps1"
        Criteria = "A, B, C"
        Iterations = 1
    },
    @{
        Name = "App Launch Performance"
        Script = "Test-AppLaunch-Remote.ps1"
        Criteria = "D"
        Iterations = 1
    },
    @{
        Name = "SMB Network Copy"
        Script = "SMB-Copy-Test.ps1"
        Criteria = "E"
        Iterations = 1
    },
    @{
        Name = "FTP Download"
        Script = "FTP-Download-Test.ps1"
        Criteria = "F"
        Iterations = 1
    }
)

$totalTests = $tests.Count

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           QUICK PIPELINE TEST - 1 ITERATION EACH             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Total Tests: $totalTests" -ForegroundColor Yellow
Write-Host "Total Iterations: $totalTests (1 per test)" -ForegroundColor Yellow
Write-Host ""

# Start timestamp
$pipelineStart = Get-Date

# Results tracking
$results = @()

# Execute each test
for ($i = 0; $i -lt $tests.Count; $i++) {
    $test = $tests[$i]
    $testNumber = $i + 1
    $percentComplete = [math]::Round((($i + 1) / $totalTests) * 100)
    
    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "│ TEST $testNumber of $totalTests : $($test.Name)" -ForegroundColor Cyan
    Write-Host "│ Criteria: $($test.Criteria)" -ForegroundColor Cyan
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
    
    # Progress bar
    $filledBars = [math]::Floor($percentComplete / 5)
    $emptyBars = 20 - $filledBars
    $progressBar = "█" * $filledBars
    $emptyBar = "░" * $emptyBars
    Write-Host "  Progress: [$progressBar$emptyBar] $percentComplete%" -ForegroundColor Yellow
    Write-Host ""
    
    $testStart = Get-Date
    
    try {
        $scriptPath = Join-Path $PSScriptRoot $test.Script
        
        if (-not (Test-Path $scriptPath)) {
            Write-Host "  ✗ ERROR: Script not found: $scriptPath" -ForegroundColor Red
            $results += @{
                Test = $test.Name
                Status = "FAILED"
                Error = "Script not found"
            }
            continue
        }
        
        Write-Host "  Executing: $($test.Script)" -ForegroundColor Gray
        Write-Host ""
        
        & $scriptPath -ConfigName $ConfigName -Iterations $test.Iterations
        
        $testEnd = Get-Date
        $testDuration = $testEnd - $testStart
        
        Write-Host ""
        Write-Host "  ✓ Completed in $($testDuration.TotalSeconds.ToString('F1'))s" -ForegroundColor Green
        
        $results += @{
            Test = $test.Name
            Status = "SUCCESS"
            Duration = $testDuration.TotalSeconds.ToString('F1')
        }
        
    } catch {
        $testEnd = Get-Date
        $testDuration = $testEnd - $testStart
        
        Write-Host ""
        Write-Host "  ✗ FAILED after $($testDuration.TotalSeconds.ToString('F1'))s" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
        
        $results += @{
            Test = $test.Name
            Status = "FAILED"
            Error = $_.Exception.Message
            Duration = $testDuration.TotalSeconds.ToString('F1')
        }
    }
}

# Pipeline complete
$pipelineEnd = Get-Date
$pipelineDuration = $pipelineEnd - $pipelineStart

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "QUICK TEST COMPLETE!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Duration: $($pipelineDuration.Minutes)m $($pipelineDuration.Seconds)s" -ForegroundColor White
Write-Host ""

# Results
$successCount = ($results | Where-Object { $_.Status -eq "SUCCESS" }).Count
$failCount = ($results | Where-Object { $_.Status -eq "FAILED" }).Count

Write-Host "Results:" -ForegroundColor Cyan
foreach ($result in $results) {
    $icon = if ($result.Status -eq "SUCCESS") { "✓" } else { "✗" }
    $color = if ($result.Status -eq "SUCCESS") { "Green" } else { "Red" }
    Write-Host "  $icon $($result.Test) - $($result.Status) ($($result.Duration)s)" -ForegroundColor $color
}

Write-Host ""
Write-Host "Total: $successCount passed, $failCount failed" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "✅ Pipeline is working! Ready for full 5-iteration run." -ForegroundColor Green
} else {
    Write-Host "⚠️  Fix errors before running full pipeline." -ForegroundColor Yellow
}
