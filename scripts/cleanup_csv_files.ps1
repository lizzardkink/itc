# CSV Files Cleanup Script
# Clears all data rows from CSV files while maintaining proper headers

param(
    [string]$RootPath = (Get-Location).Path,
    [switch]$WhatIf
)

Write-Host "CSV Cleanup Script" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host ""

# Define proper headers for each CSV type
$csvHeaders = @{
    'app-launch'     = "Iteration,Timestamp,TimeMs,TimeSeconds,Configuration"
    'boot-time'      = "Iteration,Timestamp,TimeToLogon,LogonTimeout,LogonToDesktop,TotalBootTime,Configuration"
    'ftp-download'   = "Iteration,Timestamp,FileSizeMB,DownloadTimeSeconds,SpeedMBps,Configuration"
    'process-count'  = "Iteration,Timestamp,ProcessCount,Configuration"
    'ram-startup'    = "Iteration,Timestamp,UsedMemoryMB,TotalMemoryMB,Configuration"
    'smb-copy'       = "Iteration,Timestamp,SourceSizeGB,CopyTimeSeconds,SpeedMBps,Configuration"
}

# Define paths to search
$searchPaths = @($RootPath, "C:\VMShare")

# Find all CSV files recursively from multiple paths
$csvFiles = @()
foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        Write-Host "Searching in: $path" -ForegroundColor Gray
        $files = Get-ChildItem -Path $path -Recurse -Filter "*.csv" -File -ErrorAction SilentlyContinue | Where-Object {
            $_.FullName -notlike "*\.git\*" -and 
            $_.FullName -notlike "*\node_modules\*" -and
            $_.FullName -notlike "*\.archive\*"
        }
        $csvFiles += $files
    } else {
        Write-Host "Path not found, skipping: $path" -ForegroundColor Yellow
    }
}
Write-Host ""

if ($csvFiles.Count -eq 0) {
    Write-Host "No CSV files found in: $RootPath" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($csvFiles.Count) CSV file(s):" -ForegroundColor Green
$csvFiles | ForEach-Object { Write-Host "  - $($_.FullName)" }
Write-Host ""

if ($WhatIf) {
    Write-Host "Running in WhatIf mode - no changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

$processedCount = 0
$skippedCount = 0
$errorCount = 0

foreach ($file in $csvFiles) {
    try {
        Write-Host "Processing: $($file.Name)" -ForegroundColor Cyan
        
        # Determine CSV type from filename
        $csvType = $null
        foreach ($type in $csvHeaders.Keys) {
            if ($file.Name -like "*$type*.csv") {
                $csvType = $type
                break
            }
        }
        
        if (-not $csvType) {
            Write-Host "  Skipped: Unknown CSV type (not a test data file)" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        # Get the proper header for this CSV type
        $header = $csvHeaders[$csvType]
        
        # Read the file to count rows
        $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
        $rowCount = if ($content) { 
            if ($content -is [array]) { $content.Count - 1 } else { 0 }
        } else { 
            0 
        }
        
        if ($WhatIf) {
            Write-Host "  Would clear $rowCount data row(s), setting header: $csvType" -ForegroundColor Yellow
        } else {
            # Write the proper header to the file
            Set-Content -Path $file.FullName -Value $header -Encoding UTF8
            Write-Host "  Cleared $rowCount data row(s), header set to: $csvType" -ForegroundColor Green
            $processedCount++
        }
    }
    catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "========" -ForegroundColor Cyan
if ($WhatIf) {
    Write-Host "Would process: $($csvFiles.Count) file(s)" -ForegroundColor Yellow
} else {
    Write-Host "Processed: $processedCount file(s)" -ForegroundColor Green
    Write-Host "Skipped: $skippedCount file(s)" -ForegroundColor Yellow
    Write-Host "Errors: $errorCount file(s)" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
}
