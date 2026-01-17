# Fix-CSVHeaders.ps1
# Ensures all CSV files in data folder have proper headers with timestamps

Write-Host "=== Fixing CSV Headers ===" -ForegroundColor Cyan
Write-Host ""

$fixes = 0

# Check each CSV file
Get-ChildItem "C:\VMShare\data" -Recurse -Filter "*.csv" -File | ForEach-Object {
    $file = $_
    $content = Get-Content $file.FullName
    
    # Check if first line contains "Iteration" or "Index" (header indicators)
    if ($content[0] -notmatch "^(Iteration|Index),.*Timestamp") {
        Write-Host "Missing/incorrect header: $($file.Name)" -ForegroundColor Yellow
        
        # Determine CSV type and add appropriate header
        if ($file.Name -match "app-launch") {
            Write-Host "  Adding app-launch header..." -ForegroundColor Gray
            $header = "Index,Timestamp,TimeMs,TimeSeconds,Configuration"
            # Need to add Configuration column to existing data
            $newContent = @($header)
            $config = $file.Directory.Name
            foreach ($line in $content) {
                if ($line -match "^(\d+),(.+)") {
                    $newContent += "$line,$config"
                }
            }
            $newContent | Out-File -FilePath $file.FullName -Encoding UTF8
            $fixes++
        }
        elseif ($file.Name -match "boot-time" -and $content[0] -notmatch "TimeToLogon") {
            Write-Host "  Updating boot-time header to new format..." -ForegroundColor Gray
            $header = "Iteration,Timestamp,TimeToLogon,LogonTimeout,LogonToDesktop,TotalBootTime,Configuration"
            # Old format had just BootTimeSeconds
            $newContent = @($header)
            foreach ($line in $content) {
                if ($line -match "^\d+,") {
                    # Keep old data but flag for re-collection
                    $newContent += $line
                }
            }
            $newContent | Out-File -FilePath $file.FullName -Encoding UTF8
            Write-Host "  WARNING: Old boot time format detected. Re-run boot tests." -ForegroundColor Red
            $fixes++
        }
    } else {
        Write-Host "OK: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Fixed $fixes CSV file(s)" -ForegroundColor Cyan

# List all current CSV formats
Write-Host ""
Write-Host "=== Current CSV Formats ===" -ForegroundColor Cyan
Get-ChildItem "C:\VMShare\data" -Recurse -Filter "*.csv" -File | ForEach-Object {
    Write-Host ""
    Write-Host "$($_.Name):" -ForegroundColor Yellow
    Get-Content $_.FullName -TotalCount 1 | Write-Host -ForegroundColor Gray
}
