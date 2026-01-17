# VM Guest Setup Requirements

**VM Name**: Win11  
**Host Shared Folder**: C:\VMShare  
**Guest Mapped Drive**: Z:  
**Purpose**: Automated data collection from IDS performance tests

## Prerequisites on Host

- VirtualBox installed
- VM "Win11" created with clean Windows 11 snapshot
- Shared folder configured: C:\VMShare → VM "Win11"

## Required Software on Guest (Win11 VM)

### 1. BootRacer
**Purpose**: Measure OS boot times (Criterion A)  
**Installation**: Download from official website, install with default settings  
**Configuration**: Set to export results to Z:\data\[config-name]\boot-time-[config].csv  
**Status**: Already installed per user confirmation

### 2. VirtualBox Guest Additions
**Purpose**: Enable shared folder access  
**Installation**: 
```powershell
# Mount Guest Additions ISO from VirtualBox menu: Devices → Insert Guest Additions CD
# Run from CD drive:
D:\VBoxWindowsAdditions.exe
```
**Verification**:
```powershell
net use Z: \\vboxsvr\VMShare
dir Z:\
```

### 3. PowerShell Scripts
**Purpose**: Automated testing  
**Location**: Clone repository or copy scripts to C:\scripts\  
**Required Scripts**:
- smb-copy-test.ps1 (network copy test)
- ftp-download-test.ps1 (remote download test)
- process-count-test.ps1 (process counting)
- ram-startup-test.ps1 (RAM measurement)
- sysbench-wrapper.ps1 (system benchmarks)

**Installation**:
```powershell
# Enable script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Create scripts directory
New-Item -ItemType Directory -Path C:\scripts -Force

# Copy scripts from host shared folder
Copy-Item Z:\scripts\*.ps1 -Destination C:\scripts\
```

### 4. Windows Subsystem for Linux (WSL) + sysbench
**Purpose**: System benchmarking (Criterion F)  
**Installation**:
```powershell
# Install WSL with Ubuntu
wsl --install

# After reboot, install sysbench in WSL
wsl sudo apt-get update
wsl sudo apt-get install -y sysbench

# Verify installation
wsl sysbench --version
```

### 5. AV-Bench Script
**Purpose**: Application launch performance testing (Criterion G)  
**Location**: C:\Users\[username]\ItC\AV-Bench\script.ps1  
**Status**: Already present and configured for 5 iterations  
**Output**: measurements.csv (copy to Z:\data\[config-name]\app-launch-[config].csv after each test)

### 6. Network Configuration
**Purpose**: Access QNAP NAS and DIGI Storage  
**Requirements**:
- VirtualBox network adapter set to Bridged Mode
- Obtain IP address on local network via DHCP
- Access to QNAP NAS via SMB (port 445)
- Access to DIGI Storage via FTP (port 21)

**Verification**:
```powershell
# Test QNAP connectivity
Test-NetConnection -ComputerName [QNAP-IP] -Port 445

# Test DIGI Storage connectivity
Test-NetConnection -ComputerName [DIGI-SERVER] -Port 21

# Map QNAP share (optional)
net use Q: \\[QNAP-IP]\[share-name]
```

## Configuration-Specific Software

### Baseline Configuration
- Clean Windows 11, fully updated
- No antivirus (disable Windows Defender)
- No firewall
- All measurement tools installed

### Symantec-Only Configuration
- Start from Baseline
- Install Symantec Endpoint Protection
- Update virus definitions
- Verify real-time protection active
- Keep firewall disabled

### OPNsense-Only Configuration
- Start from Baseline
- Install OPNsense or enable Windows Firewall with Advanced Security
- Configure firewall rules
- Verify firewall active
- Keep antivirus disabled

### Both Configuration
- Start from Baseline
- Install Symantec Endpoint Protection
- Install OPNsense/Firewall
- Verify both active simultaneously
- Check for conflicts

## Shared Folder Mapping

### Automatic Mapping via VirtualBox Guest Additions

Once Guest Additions are installed, add shared folder in VirtualBox settings:

1. VM Settings → Shared Folders → Add New Shared Folder
2. Folder Path: C:\VMShare
3. Folder Name: VMShare
4. ✓ Auto-mount
5. ✓ Make Permanent
6. Mount Point: Z:

### Manual Mapping (if needed)

```powershell
# Create persistent mapping
net use Z: \\vboxsvr\VMShare /persistent:yes

# Verify mapping
Get-PSDrive Z
```

### Data Collection Workflow

All test scripts should save results to Z: drive using this structure:

```
Z:\data\
├── baseline\
│   ├── smb-copy-baseline.csv
│   ├── ftp-download-baseline.csv
│   ├── process-count-baseline.csv
│   ├── ram-startup-baseline.csv
│   ├── boot-time-baseline.csv
│   ├── sysbench-baseline.csv
│   └── app-launch-baseline.csv
├── symantec\
│   └── [same structure]
├── opnsense\
│   └── [same structure]
└── both\
    └── [same structure]
```

## Test Execution Checklist

### Before Each Test Session

- [ ] Restore appropriate VM snapshot
- [ ] Verify Z: drive is mapped and accessible
- [ ] Verify network connectivity (QNAP + DIGI Storage)
- [ ] Close all unnecessary applications
- [ ] Disable Windows Update during tests
- [ ] Disable sleep/hibernate modes

### After Each Test Session

- [ ] Copy measurements.csv from AV-Bench to Z:\data\[config]\app-launch-[config].csv
- [ ] Verify all CSV files are on Z: drive
- [ ] Check file contents for completeness
- [ ] Document any anomalies or errors

## Troubleshooting

### Shared Folder Not Accessible

```powershell
# Check VirtualBox Guest Additions service
Get-Service -Name VBox*

# Restart VirtualBox service
Restart-Service -Name VBoxService

# Manually mount
net use Z: \\vboxsvr\VMShare
```

### sysbench Not Found

```powershell
# Check WSL status
wsl --status

# Reinstall sysbench
wsl sudo apt-get install --reinstall sysbench
```

### Network Tests Failing

```powershell
# Check network adapter status
Get-NetAdapter

# Verify IP configuration
ipconfig /all

# Test DNS resolution
nslookup [QNAP-IP]
nslookup [DIGI-SERVER]

# Disable/enable adapter
Disable-NetAdapter -Name "Ethernet" -Confirm:$false
Enable-NetAdapter -Name "Ethernet" -Confirm:$false
```

### BootRacer Not Exporting Data

- Check BootRacer settings → Export path set to Z:\data\...
- Verify BootRacer has write permissions to Z: drive
- Manually export after each boot if automatic export fails

## Performance Testing Best Practices

1. **Consistency**: Always start from clean snapshot for each configuration
2. **Timing**: Run tests at same time of day to minimize network variability
3. **Isolation**: Close all background applications before testing
4. **Verification**: Check variance <10% across 5 iterations
5. **Documentation**: Note any unusual behavior or environmental factors
6. **Backups**: Keep copy of all measurement data in multiple locations

## Summary

Once the guest is properly configured with:
- ✅ VirtualBox Guest Additions
- ✅ Z: drive mapped to C:\VMShare
- ✅ BootRacer installed
- ✅ WSL + sysbench installed
- ✅ PowerShell scripts in C:\scripts
- ✅ Network connectivity verified
- ✅ AV-Bench script ready

You can run the full test suite across all 4 configurations with automated data collection to the host's C:\VMShare folder.
