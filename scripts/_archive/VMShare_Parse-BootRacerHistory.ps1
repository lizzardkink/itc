# Parse-BootRacerHistory.ps1
# Parse all boot times from Bootracer.his file

$hisPath = "C:\Users\Public\Documents\Bootracer.his"

Write-Host "Parsing BootRacer boot history..." -ForegroundColor Cyan
Write-Host ""

if (Test-Path $hisPath) {
    $content = Get-Content $hisPath
    
    # Find all boot entries by looking for TimeLogonScreen entries
    $bootTimes = @()
    $currentBoot = @{}
    
    foreach ($line in $content) {
        if ($line -match "BootStart=(\d+)") {
            $currentBoot.BootStart = $matches[1]
        }
        elseif ($line -match "TimeLogonScreen=(\d+)") {
            $currentBoot.TimeLogonScreen = [int]$matches[1]
        }
        elseif ($line -match "TimeDesktopReady=(\d+)") {
            $currentBoot.TimeDesktopReady = [int]$matches[1]
        }
        elseif ($line -match "UserName=(.+)") {
            $currentBoot.UserName = $matches[1]
            # End of boot entry, save it
            if ($currentBoot.TimeLogonScreen -gt 0) {
                $bootTimes += [PSCustomObject]@{
                    BootStart = $currentBoot.BootStart
                    BootTimeSeconds = $currentBoot.TimeLogonScreen
                    DesktopReadySeconds = $currentBoot.TimeDesktopReady
                    UserName = $currentBoot.UserName
                }
            }
            $currentBoot = @{}
        }
    }
    
    # Display results
    Write-Host "Found $($bootTimes.Count) boot records:" -ForegroundColor Green
    Write-Host ""
    
    # Show last 10
    $last10 = $bootTimes | Select-Object -Last 10
    $index = $bootTimes.Count - 9
    
    Write-Host "Last 10 Boot Times:" -ForegroundColor Yellow
    Write-Host "===================" -ForegroundColor Gray
    foreach ($boot in $last10) {
        Write-Host "$index. " -NoNewline -ForegroundColor Cyan
        Write-Host "Boot Time: " -NoNewline -ForegroundColor White
        Write-Host "$($boot.BootTimeSeconds) seconds" -NoNewline -ForegroundColor Green
        Write-Host " (Desktop Ready: $($boot.DesktopReadySeconds)s)" -ForegroundColor Gray
        Write-Host "    Started: $($boot.BootStart) | User: $($boot.UserName)" -ForegroundColor DarkGray
        $index++
    }
    
} else {
    Write-Host "BootRacer.his not found!" -ForegroundColor Red
}
