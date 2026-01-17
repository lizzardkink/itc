# GUI-App-Launcher-Helper.ps1
# Runs on VM in user session to launch GUI apps requested by remote scripts

$triggerPath = "Z:\gui_trigger.txt"
$processedPath = "Z:\gui_processed.txt"

Write-Host "=== GUI App Launcher Helper ===" -ForegroundColor Green
Write-Host "Monitoring: $triggerPath" -ForegroundColor Gray
Write-Host "Session: $PID in session $((Get-Process -Id $PID).SessionId)"
Write-Host "Press Ctrl+C to stop`n"

while ($true) {
    if (Test-Path $triggerPath) {
        try {
            $request = Get-Content $triggerPath -Raw | ConvertFrom-Json
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Request: $($request.Action) $($request.App) x$($request.Count)" -ForegroundColor Cyan
            
            switch ($request.Action) {
                'Launch' {
                    for ($i = 1; $i -le $request.Count; $i++) {
                        Start-Process $request.App -WindowStyle Normal
                        Write-Host "  ✓ Launched instance $i" -ForegroundColor Green
                        Start-Sleep -Milliseconds 200
                    }
                }
                'CloseAll' {
                    $procName = $request.App -replace '\.exe$',''
                    $procs = Get-Process -Name $procName -ErrorAction SilentlyContinue
                    if ($procs) {
                        Write-Host "  Found $($procs.Count) $procName instance(s)" -ForegroundColor Gray
                        $procs | ForEach-Object {
                            if ($_.CloseMainWindow()) {
                                Write-Host "  ✓ Closed PID $($_.Id) gracefully" -ForegroundColor Green
                            }
                            Start-Sleep -Milliseconds 100
                        }
                        Start-Sleep -Seconds 1
                        # Force kill any remaining
                        $remaining = Get-Process -Name $procName -ErrorAction SilentlyContinue
                        if ($remaining) {
                            $remaining | Stop-Process -Force
                            Write-Host "  ✓ Force-killed $($remaining.Count) remaining instance(s)" -ForegroundColor Yellow
                        }
                    } else {
                        Write-Host "  No $procName processes found" -ForegroundColor Gray
                    }
                }
            }
            
            # Mark as processed
            @{
                Status = "Success"
                Timestamp = Get-Date -Format 'o'
                Request = $request
            } | ConvertTo-Json | Out-File $processedPath -Force
            
            Remove-Item $triggerPath -Force
            
        } catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
        }
    }
    
    Start-Sleep -Milliseconds 500
}
