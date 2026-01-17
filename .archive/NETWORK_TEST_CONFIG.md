# Network Test Configuration for IDS Impact Analysis

**Date**: 2026-01-16  
**Test Type**: Criterion (a) - Network Folder Copy Speed  
**Status**: ✓ Configuration determined

## Network Infrastructure

### Local Network Setup

- **Protocol**: SMB (Server Message Block)
- **Network Speed**: 1 Gigabit (1000 Mbps)
- **Source**: WIN11 VirtualBox VM
- **Destination**: QNAP NAS
- **Connection Type**: LAN (Local Area Network)

### VirtualBox Network Configuration

**Required Setting**: Bridged Adapter

```powershell
# Configure VM network adapter to Bridged mode
VBoxManage modifyvm "WIN11" --nic1 bridged --bridgeadapter1 "Your-Ethernet-Adapter-Name"
```

Or via VirtualBox GUI:
1. Select WIN11 VM
2. Settings → Network → Adapter 1
3. Attached to: **Bridged Adapter**
4. Name: Select your physical network adapter
5. Click OK

**Why Bridged?**
- VM gets IP on local network (same subnet as QNAP)
- Direct access to QNAP NAS via SMB
- No NAT translation overhead

## Test Data Preparation

### 1GB Test Folder on QNAP NAS

Create a test folder with ≥1GB data:

**Option A**: Single large file
```
\\QNAP-IP\share\test-folder\
  └── testfile.bin (1GB)
```

**Option B**: Multiple files (recommended)
```
\\QNAP-IP\share\test-folder\
  ├── file1.dat (100MB)
  ├── file2.dat (100MB)
  ├── ... (10 files total = 1GB)
```

**Why multiple files?**
- Better represents real-world usage
- Tests both file metadata and data transfer
- More sensitive to IDS scanning overhead

### Creating Test Data

On QNAP NAS or from any computer on the network:

```powershell
# Create 1GB of test data (10x 100MB files)
1..10 | ForEach-Object {
    $bytes = New-Object byte[] (100MB)
    (New-Object Random).NextBytes($bytes)
    [IO.File]::WriteAllBytes("\\QNAP-IP\share\test-folder\file$_.dat", $bytes)
}
```

Or use `fsutil` for faster creation (Windows):
```cmd
fsutil file createnew \\QNAP-IP\share\test-folder\testfile.bin 1073741824
```

## SMB Copy Testing Script

### PowerShell Script for Measurement

```powershell
# smb-copy-test.ps1
param(
    [string]$Source = "\\QNAP-IP\share\test-folder",
    [string]$Destination = "C:\Temp\test-copy",
    [int]$Iterations = 5
)

$results = @()

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "Iteration $i of $Iterations..." -ForegroundColor Cyan
    
    # Clean destination
    if (Test-Path $Destination) {
        Remove-Item $Destination -Recurse -Force
    }
    
    # Measure copy time
    $startTime = Get-Date
    Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    $endTime = Get-Date
    
    $duration = ($endTime - $startTime).TotalSeconds
    $sizeGB = (Get-ChildItem $Destination -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB
    $speedMBps = ($sizeGB * 1024) / $duration
    
    $results += [PSCustomObject]@{
        Iteration = $i
        Duration_Seconds = [math]::Round($duration, 2)
        Size_GB = [math]::Round($sizeGB, 3)
        Speed_MBps = [math]::Round($speedMBps, 2)
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    Write-Host "  Duration: $([math]::Round($duration, 2))s | Speed: $([math]::Round($speedMBps, 2)) MB/s" -ForegroundColor Green
    
    # Cleanup
    Remove-Item $Destination -Recurse -Force
    Start-Sleep -Seconds 5
}

# Export results
$results | Export-Csv "smb-copy-results.csv" -NoTypeInformation
$results | Format-Table -AutoSize

# Calculate statistics
$avgSpeed = ($results | Measure-Object -Property Speed_MBps -Average).Average
$minSpeed = ($results | Measure-Object -Property Speed_MBps -Minimum).Minimum
$maxSpeed = ($results | Measure-Object -Property Speed_MBps -Maximum).Maximum

Write-Host "`nStatistics:" -ForegroundColor Yellow
Write-Host "  Average Speed: $([math]::Round($avgSpeed, 2)) MB/s"
Write-Host "  Min Speed: $([math]::Round($minSpeed, 2)) MB/s"
Write-Host "  Max Speed: $([math]::Round($maxSpeed, 2)) MB/s"
Write-Host "  Variance: $([math]::Round((($maxSpeed - $minSpeed) / $avgSpeed) * 100, 2))%"
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

3. **Verify network connectivity**
   - Ping QNAP NAS: `ping QNAP-IP`
   - Test SMB access: `dir \\QNAP-IP\share`

4. **Run SMB copy test**
   ```powershell
   .\smb-copy-test.ps1 -Source "\\QNAP-IP\share\test-folder" -Iterations 5
   ```

5. **Record results**
   - Save CSV file with configuration label
   - Rename: `smb-copy-results-baseline.csv`, `smb-copy-results-symantec.csv`, etc.

6. **Shutdown VM**

7. **Repeat for next configuration**

## Expected Performance

### Baseline (No IDS)
- **Theoretical Max**: ~125 MB/s (1 Gbit = 125 MB/s)
- **Expected Actual**: 80-110 MB/s (accounting for overhead)
- **Time for 1GB**: ~10-13 seconds

### With IDS (Estimated)
- **AV scanning overhead**: 10-30% slower
- **Firewall filtering**: 5-15% slower
- **Combined**: 15-40% slower
- **Expected time**: 13-20 seconds

## Rationale for Paper

**Why SMB on Local Network?**

"SMB (Server Message Block) protocol was selected for the network file transfer test (Criterion a) as it represents the most common enterprise file sharing protocol in Windows environments. The test measured recursive copy of a 1GB folder from a QNAP NAS over a 1 Gigabit LAN connection, simulating real-world file server access patterns where antivirus and firewall inspection of network traffic can introduce measurable latency."

## VirtualBox Network Verification

### Check current network configuration:
```powershell
VBoxManage showvminfo "WIN11" | Select-String "NIC"
```

### Verify VM can access QNAP:
From within WIN11 VM:
```powershell
# Test connectivity
Test-NetConnection -ComputerName QNAP-IP -Port 445

# Test SMB access
Get-SmbConnection

# List available shares
net view \\QNAP-IP
```

## Troubleshooting

### VM cannot access QNAP NAS
- Check VirtualBox network mode is Bridged
- Verify host computer can access QNAP
- Check Windows Firewall in VM is not blocking SMB
- Ensure QNAP share permissions allow VM access

### Slow SMB performance
- Verify 1Gbit link speed: `Get-NetAdapter | Select-Object Name, LinkSpeed`
- Check for background processes consuming bandwidth
- Disable Windows Search indexing on test folder
- Ensure QNAP NAS is not under heavy load

### Inconsistent results (>10% variance)
- Run more iterations (7-10 instead of 5)
- Check for QNAP background tasks (virus scan, backup)
- Ensure host system is not throttling VM
- Verify no other network traffic during test

## Data Collection

Results for paper:

| Configuration | Avg Speed (MB/s) | Duration (s) | Overhead (%) |
|---------------|------------------|--------------|--------------|
| Baseline      | ___ | ___ | - |
| Symantec      | ___ | ___ | ___ |
| OPNsense      | ___ | ___ | ___ |
| Both          | ___ | ___ | ___ |

Calculate overhead: `((Baseline_Speed - Config_Speed) / Baseline_Speed) * 100`

## References

- SMB Protocol: https://docs.microsoft.com/en-us/windows-server/storage/file-server/file-server-smb-overview
- QNAP NAS Documentation: https://www.qnap.com/
