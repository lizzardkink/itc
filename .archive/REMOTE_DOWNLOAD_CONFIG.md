# Remote Download Test Configuration for IDS Impact Analysis

**Date**: 2026-01-16  
**Test Type**: Criterion (b) - Remote File Download Speed  
**Status**: ✓ Configuration determined

## Remote Server Configuration

### DIGI Storage Server

- **Server**: DIGI Storage
- **Protocol**: FTP (File Transfer Protocol)
- **Connection**: Internet/WAN (long-distance)
- **Test File Size**: ≥100MB
- **Purpose**: Measure download speed with IDS inspection overhead

## FTP Connection Setup

### Windows Built-in FTP Client

PowerShell approach (recommended):
```powershell
# Test FTP connection
$ftpUri = "ftp://digi-storage-server/testfile.bin"
$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential("username", "password")
$webclient.DownloadFile($ftpUri, "C:\Temp\testfile.bin")
```

### Alternative: Third-Party FTP Clients

**Option 1**: WinSCP (command-line mode)
```powershell
# Install WinSCP first
winscp.com /command "open ftp://username:password@digi-storage-server" "get /testfile.bin C:\Temp\" "exit"
```

**Option 2**: FileZilla CLI
```powershell
# Command-line FTP download
```

**Option 3**: curl (if available)
```powershell
curl -u username:password ftp://digi-storage-server/testfile.bin -o C:\Temp\testfile.bin
```

## Test File Preparation on DIGI Storage

### Create 100MB Test File

On DIGI Storage server or upload from any device:

```powershell
# Create 100MB file locally, then upload to DIGI Storage
$bytes = New-Object byte[] (100MB)
(New-Object Random).NextBytes($bytes)
[IO.File]::WriteAllBytes("testfile.bin", $bytes)

# Upload via FTP (example with PowerShell)
$ftpUri = "ftp://digi-storage-server/testfile.bin"
$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential("username", "password")
$webclient.UploadFile($ftpUri, "testfile.bin")
```

## FTP Download Testing Script

### PowerShell Script for Measurement

```powershell
# ftp-download-test.ps1
param(
    [string]$FtpServer = "digi-storage-server",
    [string]$FtpUsername = "username",
    [string]$FtpPassword = "password",
    [string]$FtpFile = "/testfile.bin",
    [string]$LocalPath = "C:\Temp\download-test.bin",
    [int]$Iterations = 5
)

$results = @()
$ftpUri = "ftp://$FtpServer$FtpFile"

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "Iteration $i of $Iterations..." -ForegroundColor Cyan
    
    # Clean local file
    if (Test-Path $LocalPath) {
        Remove-Item $LocalPath -Force
    }
    
    # Measure download time
    $startTime = Get-Date
    
    try {
        $webclient = New-Object System.Net.WebClient
        $webclient.Credentials = New-Object System.Net.NetworkCredential($FtpUsername, $FtpPassword)
        $webclient.DownloadFile($ftpUri, $LocalPath)
        
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        $sizeMB = (Get-Item $LocalPath).Length / 1MB
        $speedMbps = ($sizeMB * 8) / $duration
        $speedMBps = $sizeMB / $duration
        
        $results += [PSCustomObject]@{
            Iteration = $i
            Duration_Seconds = [math]::Round($duration, 2)
            Size_MB = [math]::Round($sizeMB, 2)
            Speed_Mbps = [math]::Round($speedMbps, 2)
            Speed_MBps = [math]::Round($speedMBps, 2)
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status = "Success"
        }
        
        Write-Host "  Duration: $([math]::Round($duration, 2))s | Speed: $([math]::Round($speedMbps, 2)) Mbps ($([math]::Round($speedMBps, 2)) MB/s)" -ForegroundColor Green
        
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
        
        $results += [PSCustomObject]@{
            Iteration = $i
            Duration_Seconds = 0
            Size_MB = 0
            Speed_Mbps = 0
            Speed_MBps = 0
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status = "Failed: $($_.Exception.Message)"
        }
    }
    
    # Cleanup
    if (Test-Path $LocalPath) {
        Remove-Item $LocalPath -Force
    }
    
    # Wait between iterations
    if ($i -lt $Iterations) {
        Start-Sleep -Seconds 5
    }
}

# Export results
$results | Export-Csv "ftp-download-results.csv" -NoTypeInformation
$results | Format-Table -AutoSize

# Calculate statistics (only successful downloads)
$successful = $results | Where-Object { $_.Status -eq "Success" }

if ($successful.Count -gt 0) {
    $avgSpeed = ($successful | Measure-Object -Property Speed_Mbps -Average).Average
    $minSpeed = ($successful | Measure-Object -Property Speed_Mbps -Minimum).Minimum
    $maxSpeed = ($successful | Measure-Object -Property Speed_Mbps -Maximum).Maximum
    
    Write-Host "`nStatistics (Successful Downloads):" -ForegroundColor Yellow
    Write-Host "  Average Speed: $([math]::Round($avgSpeed, 2)) Mbps"
    Write-Host "  Min Speed: $([math]::Round($minSpeed, 2)) Mbps"
    Write-Host "  Max Speed: $([math]::Round($maxSpeed, 2)) Mbps"
    Write-Host "  Variance: $([math]::Round((($maxSpeed - $minSpeed) / $avgSpeed) * 100, 2))%"
    Write-Host "  Success Rate: $($successful.Count)/$($Iterations)"
} else {
    Write-Host "`n⚠ All downloads failed!" -ForegroundColor Red
}
```

## Testing Procedure

### For Each Configuration (No IDS, Symantec, OPNsense, Both):

1. **Restore VM snapshot**
   ```powershell
   VBoxManage snapshot "WIN11" restore "Baseline-NoIDS"
   ```

2. **Start VM**
   ```powershell
   VBoxManage startvm "WIN11"
   ```

3. **Verify internet connectivity**
   ```powershell
   Test-NetConnection -ComputerName digi-storage-server -Port 21
   ping digi-storage-server
   ```

4. **Test FTP access**
   ```powershell
   # Quick FTP test
   ftp digi-storage-server
   # Login with credentials
   # Type 'ls' to list files
   # Type 'quit' to exit
   ```

5. **Run FTP download test**
   ```powershell
   .\ftp-download-test.ps1 -FtpServer "digi-storage-server" `
                            -FtpUsername "your-username" `
                            -FtpPassword "your-password" `
                            -FtpFile "/testfile.bin" `
                            -Iterations 5
   ```

6. **Record results**
   - Save CSV file with configuration label
   - Rename: `ftp-download-baseline.csv`, `ftp-download-symantec.csv`, etc.

7. **Shutdown VM**

8. **Repeat for next configuration**

## Expected Performance

### Baseline (No IDS)
- **Depends on**: Internet connection speed, DIGI Storage bandwidth
- **Typical residential**: 50-200 Mbps download
- **Example**: 100MB @ 100 Mbps = ~8 seconds

### With IDS (Estimated)
- **AV deep packet inspection**: 5-20% slower
- **Firewall packet filtering**: 5-15% slower
- **Combined overhead**: 10-30% slower
- **Example**: 100MB might take 9-11 seconds instead of 8

### Factors Affecting Speed
- Internet connection bandwidth (bottleneck)
- DIGI Storage server load
- Network congestion (time of day)
- FTP vs FTPS (encrypted FTP is slower)

## Rationale for Paper

**Why FTP to DIGI Storage?**

"FTP protocol was selected for the remote file download test (Criterion b) to measure long-distance network performance. A 100MB file was downloaded from DIGI Storage server over the internet, representing real-world scenarios where IDS software inspects inbound traffic from external sources. This test evaluates the computational overhead of deep packet inspection, protocol analysis, and threat detection on download throughput."

## FTP Connection Verification

### Test FTP connectivity:
```powershell
# Basic connectivity test
Test-NetConnection -ComputerName digi-storage-server -Port 21

# Test FTP login (interactive)
ftp digi-storage-server

# Test with PowerShell WebClient
$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential("username", "password")
$webclient.DownloadString("ftp://digi-storage-server/")
```

### Check available bandwidth:
```powershell
# Test internet speed (external tool)
# Use speedtest-cli or online speed test to establish baseline
```

## Troubleshooting

### Cannot connect to FTP server
- Verify FTP server address and port (default: 21)
- Check firewall in VM allows outbound FTP
- Verify credentials (username/password)
- Test from host machine first to rule out network issues

### Slow download speed
- Check internet connection speed
- Verify DIGI Storage is not rate-limited
- Test at different times (network congestion)
- Consider server-side bandwidth limits

### Authentication failures
- Verify FTP credentials are correct
- Check if anonymous FTP is allowed (if not using credentials)
- Some FTP servers require FTPS (secure FTP)

### Inconsistent results (>20% variance)
- Internet speed varies naturally
- Run more iterations (7-10 instead of 5)
- Test at consistent time of day
- Document network conditions in paper

## Alternative: Using curl for FTP

If PowerShell WebClient has issues:

```powershell
# Download with curl (if available)
Measure-Command {
    curl -u username:password ftp://digi-storage-server/testfile.bin -o C:\Temp\test.bin
}

# Repeat in loop for multiple iterations
1..5 | ForEach-Object {
    $duration = Measure-Command {
        curl -u username:password ftp://digi-storage-server/testfile.bin -o C:\Temp\test.bin
    }
    Write-Host "Iteration $_: $($duration.TotalSeconds) seconds"
    Remove-Item C:\Temp\test.bin -Force
    Start-Sleep -Seconds 5
}
```

## Data Collection

Results for paper:

| Configuration | Avg Speed (Mbps) | Duration (s) | Overhead (%) |
|---------------|------------------|--------------|--------------|
| Baseline      | ___ | ___ | - |
| Symantec      | ___ | ___ | ___ |
| OPNsense      | ___ | ___ | ___ |
| Both          | ___ | ___ | ___ |

Calculate overhead: `((Baseline_Speed - Config_Speed) / Baseline_Speed) * 100`

## Security Note

**Credentials in Scripts**: For testing purposes, credentials may be hardcoded in scripts. For production or shared environments:
- Use credential managers
- Prompt for credentials: `Get-Credential`
- Use environment variables

Example with credential prompt:
```powershell
$cred = Get-Credential -Message "Enter FTP credentials"
$webclient.Credentials = $cred
```

## References

- FTP Protocol: https://en.wikipedia.org/wiki/File_Transfer_Protocol
- PowerShell WebClient: https://docs.microsoft.com/en-us/dotnet/api/system.net.webclient
