# ItC - Antivirus Benchmark Project

**Impact of Security Software on Windows 11 VM Performance**

## Project Overview

This project benchmarks the performance impact of security software (Symantec Endpoint Protection) and Windows Firewall on a Windows 11 virtual machine across 6 performance criteria.

## Test Configurations

The project tests **4 configurations**:

1. **baseline** - Clean system with no security software
2. **antivirus** - Symantec Endpoint Protection only
3. **firewall** - Windows Firewall only
4. **both** - Both Symantec Endpoint Protection + Windows Firewall

## Performance Criteria

### A. Boot Time (seconds)
- Measures total time from VM start to desktop ready
- Data source: BootRacer application
- Target: < 90 seconds

### B. Process Count
- Measures number of running processes after boot
- Lower is better (indicates less overhead)

### C. RAM Usage at Startup (MB)
- Measures memory consumption after boot
- Shows impact on available system resources

### D. Application Launch Time (seconds)
- Measures time to launch 75 applications (25 Calc + 25 Notepad + 25 Paint)
- Tests real-world application responsiveness

### E. SMB Network Copy Speed (MB/s)
- Copies test data from QNAP NAS (\\192.168.1.126\Public\test) to VM
- Tests network throughput with security scanning

### F. FTP Download Speed (MB/s)
- Downloads test file from DIGI Storage (ftp://192.168.1.125)
- Tests internet/external network performance

## Directory Structure

```
ItC/
├── scripts/                          # Test automation scripts
│   ├── Automated-Boot-Cycle-With-BootRacer.ps1
│   ├── Test-AppLaunch-Remote.ps1
│   ├── SMB-Copy-Test.ps1
│   ├── FTP-Download-Test.ps1
│   ├── Run-Baseline-Full-Pipeline.ps1
│   ├── Run-Antivirus-Full-Pipeline.ps1
│   ├── Run-Firewall-Full-Pipeline.ps1
│   ├── Run-Both-Full-Pipeline.ps1
│   ├── Run-All-Configurations.bat   # Master batch file
│   └── Test-Pipeline-Quick.ps1      # Quick validation (1 iteration)
├── specs/                            # Project specifications
│   └── 001-av-benchmark/
├── analysis/                         # Data analysis scripts
└── C:\VMShare\                       # Shared folder with VM
    ├── data/                         # Test results
    │   ├── baseline/                 # 6 CSV files
    │   ├── antivirus/                # 6 CSV files
    │   ├── firewall/                 # 6 CSV files
    │   └── both/                     # 6 CSV files
    └── *.ps1                         # VM helper scripts
```

## Data Files

Each configuration folder contains **6 CSV files** with timestamps:

1. `boot-time-{config}.csv` - Boot time measurements (Criteria A)
2. `ram-startup-{config}.csv` - RAM usage at startup (Criteria C)
3. `process-count-{config}.csv` - Process count (Criteria B)
4. `app-launch-{config}.csv` - Application launch times (Criteria D)
5. `smb-copy-{config}.csv` - SMB network copy performance (Criteria E)
6. `ftp-download-{config}.csv` - FTP download performance (Criteria F)

**Total: 24 CSV files** (4 configs × 6 criteria)

## Running Tests

### Quick Test (1 iteration per test)
```powershell
.\scripts\Test-Pipeline-Quick.ps1 -ConfigName "baseline"
```

### Full Pipeline (5 iterations per test)

**Single configuration:**
```powershell
.\scripts\Run-Baseline-Full-Pipeline.ps1
```

**All configurations:**
```cmd
.\scripts\Run-All-Configurations.bat
```

This will:
1. Run baseline tests (5 iterations each)
2. Prompt to install Symantec
3. Run antivirus tests (5 iterations each)
4. Prompt to uninstall Symantec and enable Firewall
5. Run firewall tests (5 iterations each)
6. Prompt to re-install Symantec
7. Run both tests (5 iterations each)

**Total time: ~100 minutes** (25 minutes per configuration)

## Test Environment

### Host System
- **OS**: Windows (IPHONE)
- **VM Software**: Oracle VirtualBox
- **VBoxManage**: `C:\Program Files\Oracle\VirtualBox\VBoxManage.exe`

### VM Specifications
- **Name**: WIN11
- **OS**: Windows 11
- **RAM**: 8 GB
- **User**: admin
- **Password**: admin
- **Shared Folder**: Z:\ (mounted to C:\VMShare on host)

### Network Resources
- **NAS**: QNAP at 192.168.1.126 (SMB share: \\192.168.1.126\Public\test)
- **FTP**: DIGI Storage at ftp://192.168.1.125

## Key Scripts

### Test Scripts (Host)
- **Automated-Boot-Cycle-With-BootRacer.ps1** - Reboots VM and measures boot time, RAM, process count
- **Test-AppLaunch-Remote.ps1** - Launches 75 apps in random order and measures time
- **SMB-Copy-Test.ps1** - Copies test data from NAS and measures speed
- **FTP-Download-Test.ps1** - Downloads test file and measures speed

### Pipeline Scripts (Host)
- **Run-{Config}-Full-Pipeline.ps1** - Runs all 4 tests with 5 iterations for one config
- **Run-All-Configurations.bat** - Runs all 4 configs sequentially with prompts

### Helper Scripts (VM)
- **VM-Helper-App-Launch.ps1** - Launches randomized apps
- **VM-Helper-SMB-Copy.ps1** - Performs SMB copy
- **VM-Helper-FTP-Download.ps1** - Performs FTP download
- **Get-LatestBootTime.ps1** - Reads BootRacer data
- **Get-MemoryInfo.ps1** - Gets RAM usage
- **Get-StartupInfo.ps1** - Gets process count

## Remote Control Method

All tests use **VBoxManage guest control** to remotely execute commands in the VM:

```powershell
VBoxManage guestcontrol WIN11 --username admin --password admin run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" --wait-stdout -- -File "Z:\script.ps1"
```

This method is reliable and doesn't require WinRM or other remote management tools.

## Data Analysis

Results are stored in CSV format with timestamps for later statistical analysis comparing the 4 configurations across all 6 criteria.

## Notes

- All CSV files include timestamps for temporal analysis
- Each test iteration is independent
- VM is rebooted between boot cycle iterations for accuracy
- Test data is cleaned up after each iteration to avoid disk space issues

## Status

✅ **Production Ready** - All scripts tested and aligned with 4-configuration structure
