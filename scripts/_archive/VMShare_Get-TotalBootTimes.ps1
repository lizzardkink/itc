# Get-TotalBootTimes.ps1
# Calculate TOTAL boot times from BootRacer CSV (all components)

$csvPath = "C:\Users\admin\Desktop\BootRacer_history.CSV"

Write-Host "Calculating TOTAL Boot Times from BootRacer..." -ForegroundColor Cyan
Write-Host ""

if (Test-Path $csvPath) {
    # Import CSV
    $data = Import-Csv $csvPath
    
    Write-Host "Last 10 TOTAL Boot Times:" -ForegroundColor Yellow
    Write-Host "=========================" -ForegroundColor Gray
    Write-Host ""
    
    $last10 = $data | Select-Object -Last 10
    $index = ($data.Count - 9)
    
    foreach ($boot in $last10) {
        $timeToLogon = [int]$boot."Time to`nLogon"
        $logonTimeout = [int]$boot."Logon`nTimeout"
        $logonToDesktop = [int]$boot."Logon to`nDesktop"
        
        # TOTAL = Time to Logon + Logon Timeout + Logon to Desktop
        $totalBootTime = $timeToLogon + $logonTimeout + $logonToDesktop
        
        $datetime = $boot."Boot Finish Date/Time"
        $grade = $boot.Grade
        
        Write-Host "$index. " -NoNewline -ForegroundColor Cyan
        Write-Host "TOTAL BOOT TIME: " -NoNewline -ForegroundColor White
        Write-Host "$totalBootTime seconds" -NoNewline -ForegroundColor Green
        if ($grade) {
            Write-Host " [$grade]" -NoNewline -ForegroundColor Yellow
        }
        Write-Host ""
        Write-Host "   Time to Logon: $timeToLogon s | Logon Timeout: $logonTimeout s | Logon to Desktop: $logonToDesktop s" -ForegroundColor Gray
        Write-Host "   Finished: $datetime" -ForegroundColor DarkGray
        Write-Host ""
        
        $index++
    }
    
    # Calculate statistics
    $allTotals = @()
    foreach ($boot in $data) {
        $timeToLogon = [int]$boot."Time to`nLogon"
        $logonTimeout = [int]$boot."Logon`nTimeout"
        $logonToDesktop = [int]$boot."Logon to`nDesktop"
        $allTotals += ($timeToLogon + $logonTimeout + $logonToDesktop)
    }
    
    $avg = [math]::Round(($allTotals | Measure-Object -Average).Average, 2)
    $min = ($allTotals | Measure-Object -Minimum).Minimum
    $max = ($allTotals | Measure-Object -Maximum).Maximum
    
    Write-Host "=========================" -ForegroundColor Gray
    Write-Host "Statistics (all $($data.Count) boots):" -ForegroundColor Cyan
    Write-Host "  Average: $avg seconds" -ForegroundColor White
    Write-Host "  Minimum: $min seconds" -ForegroundColor Green
    Write-Host "  Maximum: $max seconds" -ForegroundColor Red
    
} else {
    Write-Host "CSV file not found at: $csvPath" -ForegroundColor Red
}
