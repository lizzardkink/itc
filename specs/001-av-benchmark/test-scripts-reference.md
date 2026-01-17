# Test Scripts Reference

## Overview
All test scripts use VBoxManage guest control to execute commands on the VM (WIN11) from the host (IPHONE). Scripts are organized into two locations:

- **Host Scripts** (`scripts/`): Main test orchestration scripts run from the host
- **VM Helper Scripts** (`C:\VMShare\`): Helper scripts executed inside the VM via VBoxManage

## Architecture

```
Host (IPHONE)                          VM (WIN11)
┌─────────────────────┐                ┌──────────────────────┐
│  Main Test Scripts  │                │   Helper Scripts     │
│  (scripts/)         │──VBoxManage──→│   (Z:\)              │
│                     │                │                      │
│  Data Collection    │←──CSV Data────│   Measurements       │
│  (C:\VMShare\data\) │                │   (BootRacer, etc)  │
└─────────────────────┘                └──────────────────────┘
```

## Test Scripts by Criterion

### Criterion A: Boot Time (Priority P1)
**Main Script:** `Automated-Boot-Cycle-With-BootRacer.ps1`
- Performs automated VM reboot cycles
- Collects boot time, RAM usage, and process count
- Uses graceful ACPI shutdown and GUI startup

**VM Helper Scripts:**
- `Get-LatestBootTime.ps1` - Reads BootRacer .his file and extracts latest boot time
- `Get-MemoryInfo.ps1` - Collects RAM usage statistics

**Data Output:**
- `C:\VMShare\data\{config}\boot-time-{config}.csv`
- `C:\VMShare\data\{config}\ram-startup-{config}.csv`
- `C:\VMShare\data\{config}\process-count-{config}.csv`

**Usage:**
```powershell
.\scripts\Automated-Boot-Cycle-With-BootRacer.ps1 -ConfigName "baseline" -Iterations 5
```

---

### Criterion B: RAM Usage (Priority P1)
**Included in:** `Automated-Boot-Cycle-With-BootRacer.ps1`

**VM Helper Script:**
- `Get-MemoryInfo.ps1` - Uses Get-CimInstance to get memory statistics

**Measurements:**
- Total RAM (MB)
- Used RAM (MB)
- Free RAM (MB)
- Usage Percentage

---

### Criterion C: Process Count (Priority P1)
**Included in:** `Automated-Boot-Cycle-With-BootRacer.ps1`

**Collection Method:** VBoxManage executes `Get-Process` directly on VM

---

### Criterion D: Application Launch Time (Priority P2)
**Main Script:** `Test-AppLaunch-Remote.ps1`
- Launches 75 applications (25 Calc + 25 Notepad + 25 Paint)
- Randomized launch order
- Measures total time to launch all apps

**VM Helper Script:**
- `VM-Helper-App-Launch.ps1` - Performs actual app launches and cleanup

**Data Output:**
- `C:\VMShare\data\{config}\app-launch-{config}.csv`

**Usage:**
```powershell
.\scripts\Test-AppLaunch-Remote.ps1 -ConfigName "baseline" -Iterations 5
```

---

### Criterion E: Network File Copy (SMB) (Priority P2)
**Main Script:** `SMB-Copy-Test.ps1`
- Copies files from QNAP NAS (192.168.50.99) to VM
- Dynamically measures whatever content is in Test folder
- Calculates transfer speed

**VM Helper Script:**
- `VM-Helper-SMB-Copy.ps1` - Performs network copy using direct UNC path

**Data Output:**
- `C:\VMShare\data\{config}\smb-copy-{config}.csv`

**Usage:**
```powershell
.\scripts\SMB-Copy-Test.ps1 -ConfigName "baseline" -Iterations 5
```

---

### Criterion F: Internet Download (FTP) (Priority P2)
**Main Script:** `FTP-Download-Test.ps1`
- Downloads 200MB file from DIGI Storage
- Measures download time and speed

**VM Helper Script:**
- `VM-Helper-FTP-Download.ps1` - Performs FTP download using .NET FtpWebRequest

**Data Output:**
- `C:\VMShare\data\{config}\ftp-download-{config}.csv`

**Usage:**
```powershell
.\scripts\FTP-Download-Test.ps1 -ConfigName "baseline" -Iterations 5
```

---

## Utility Scripts

### Invoke-VMCommand.ps1
**Purpose:** General utility for executing commands on VM via VBoxManage

**Usage:**
```powershell
.\scripts\Invoke-VMCommand.ps1 -Command "Get-Process"
.\scripts\Invoke-VMCommand.ps1 -ScriptPath "Z:\script.ps1"
```

### Analyze-AllData.ps1
**Purpose:** Analyzes collected CSV data and generates reports

**Usage:**
```powershell
.\scripts\Analyze-AllData.ps1
```

---

## VM Helper Scripts Detail

All VM helper scripts are stored in `C:\VMShare\` (mapped as `Z:\` on the VM) and are called by the main test scripts via VBoxManage.

### Get-LatestBootTime.ps1
**Called by:** Automated-Boot-Cycle-With-BootRacer.ps1

**Function:** Reads `C:\Users\Public\Documents\Bootracer.his` and extracts the most recent boot time

**Output Format:** `TimeToLogon|LogonTimeout|TimeDesktopReady|TotalBootTime`

**Example:** `19|0|82|82`

### Get-MemoryInfo.ps1
**Called by:** Automated-Boot-Cycle-With-BootRacer.ps1

**Function:** Uses Get-CimInstance Win32_OperatingSystem to get memory stats

**Output Format:** `TotalMB|UsedMB|FreeMB|UsedPercent`

**Example:** `8172.88|2132.13|6040.75|26.09`

### VM-Helper-App-Launch.ps1
**Called by:** Test-AppLaunch-Remote.ps1

**Function:** 
- Creates array of all apps to launch
- Randomizes launch order using `Sort-Object { Get-Random }`
- Launches apps with 50ms delay between each
- Cleans up all launched processes

**Output Format:** `TimeMs|TimeSeconds`

**Example:** `48964.0405|48.964`

### VM-Helper-FTP-Download.ps1
**Called by:** FTP-Download-Test.ps1

**Function:**
- Downloads file from DIGI Storage FTP server
- Measures file size and download time
- Calculates transfer speed
- Cleans up downloaded file

**Output Format:** `FileSizeMB|DownloadTimeSeconds|SpeedMBps`

**Example:** `202.09|8.4248734|23.99`

### VM-Helper-SMB-Copy.ps1
**Called by:** SMB-Copy-Test.ps1

**Function:**
- Accesses QNAP NAS via direct UNC path
- Calculates total size of files in Test folder
- Copies all files to VM desktop
- Measures time and calculates speed
- Cleans up copied files

**Output Format:** `SourceSizeGB|CopyTimeSeconds|SpeedMBps`

**Example:** `1.01|28.9139301|35.92`

---

## VBoxManage Integration

All main test scripts use VBoxManage guest control with the following pattern:

```powershell
$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VMName = "WIN11"
$vmUser = "admin"
$vmPass = "admin"

$result = & $VBoxManage guestcontrol $VMName `
    --username $vmUser --password $vmPass `
    run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    --wait-stdout --wait-stderr `
    -- powershell.exe -ExecutionPolicy Bypass -File "Z:\VM-Helper-Script.ps1"
```

---

## Data Collection Flow

1. **Test Initiation:** User runs main test script from host
2. **VM Execution:** VBoxManage sends command to VM
3. **Helper Execution:** VM runs helper script in VMShare (Z:\)
4. **Data Collection:** Helper script performs measurements
5. **Output Format:** Helper returns pipe-delimited data
6. **CSV Storage:** Main script parses output and saves to CSV
7. **Shared Folder:** Data stored in C:\VMShare\data\{config}\

---

## Configuration Names

Tests support 4 configurations:
- `baseline` - No security software
- `symantec` - Symantec Endpoint Protection only
- `firewall` - Windows Firewall only
- `both` - Both Symantec and Firewall

---

## Testing Iterations

All tests support multiple iterations via `-Iterations` parameter:
- **Minimum:** 1 (for testing)
- **Production:** 5 (as per research methodology)
- **Boot Cycle:** First iteration uses running VM, subsequent iterations perform full reboot

---

## CSV Output Format

All CSV files include:
- **Iteration** number
- **Timestamp** (ISO 8601 format: yyyy-MM-ddTHH:mm:ss)
- **Measurement data** (criterion-specific)
- **Configuration** name

Example CSV headers:
```
Iteration,Timestamp,TimeToLogon,LogonTimeout,TimeDesktopReady,TotalBootTime,Configuration
Iteration,Timestamp,TotalMB,UsedMB,FreeMB,UsedPercent,Configuration
Iteration,Timestamp,ProcessCount,Configuration
Iteration,Timestamp,TimeMs,TimeSeconds,Configuration
Iteration,Timestamp,SourceSizeGB,CopyTimeSeconds,SpeedMBps,Configuration
Iteration,Timestamp,FileSizeMB,DownloadTimeSeconds,SpeedMBps,Configuration
```

---

## Cross-Reference Matrix

| Criterion | Main Script | VM Helper(s) | Data File(s) |
|-----------|-------------|--------------|--------------|
| **A: Boot Time** | Automated-Boot-Cycle-With-BootRacer.ps1 | Get-LatestBootTime.ps1<br>Get-MemoryInfo.ps1 | boot-time-{config}.csv<br>ram-startup-{config}.csv<br>process-count-{config}.csv |
| **B: RAM Usage** | (same as A) | Get-MemoryInfo.ps1 | ram-startup-{config}.csv |
| **C: Process Count** | (same as A) | (direct VBoxManage) | process-count-{config}.csv |
| **D: App Launch** | Test-AppLaunch-Remote.ps1 | VM-Helper-App-Launch.ps1 | app-launch-{config}.csv |
| **E: SMB Copy** | SMB-Copy-Test.ps1 | VM-Helper-SMB-Copy.ps1 | smb-copy-{config}.csv |
| **F: FTP Download** | FTP-Download-Test.ps1 | VM-Helper-FTP-Download.ps1 | ftp-download-{config}.csv |

---

## Troubleshooting

### VM Not Responding
- Check VM state: `VBoxManage showvminfo WIN11 --machinereadable`
- Verify guest additions are running
- Check Z:\ drive is mounted in VM

### Helper Script Fails
- Run helper script manually from VM: `powershell -ExecutionPolicy Bypass -File Z:\script.ps1`
- Check script output for errors
- Verify required resources (BootRacer, NAS, FTP) are accessible

### Data Not Saved
- Verify C:\VMShare\data\{config}\ folder exists
- Check CSV file permissions
- Review main script output for parsing errors

---

## Version History

- **2026-01-17**: All scripts converted to VBoxManage guest control
- **2026-01-17**: Boot time calculation corrected (TimeDesktopReady is total)
- **2026-01-17**: App launch randomization implemented
- **2026-01-17**: SMB test updated to use direct UNC path (dynamic content)
- **2026-01-17**: Documentation created with full cross-references
