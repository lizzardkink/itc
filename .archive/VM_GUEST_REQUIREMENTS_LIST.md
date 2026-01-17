# VM Guest Setup Requirements

**VM Name**: Win11  
**Purpose**: IDS Impact Analysis Testing  
**Host Shared Folder**: C:\VMShare (host) → Z: (guest)

## Prerequisites

- [ ] VirtualBox installed on host
- [ ] Win11 VM created with clean Windows 11 installation
- [ ] Baseline snapshot exists (OS updated, no antivirus/firewall)
- [ ] Shared folder C:\VMShare created on host computer

## Network Configuration

### 1. VirtualBox Network Adapter
- [ ] Set VM network adapter to **Bridged Mode**
- [ ] Select correct physical Ethernet adapter (1 Gigabit)
- [ ] Verify VM can access local network (192.168.x.x range)

### 2. SMB Access to QNAP NAS
- [ ] Verify network connectivity: `Test-NetConnection -ComputerName QNAP-IP -Port 445`
- [ ] Map network drive to QNAP NAS (for manual testing if needed)
- [ ] Confirm access to 1GB test folder on QNAP

### 3. FTP Access to DIGI Storage
- [ ] Verify FTP connectivity: `Test-NetConnection -ComputerName digi-server -Port 21`
- [ ] Test FTP credentials work
- [ ] Confirm 100MB test file is accessible

## Shared Folder Configuration

### 4. VirtualBox Shared Folder Setup
- [ ] Install VirtualBox Guest Additions in Win11 VM
- [ ] Create shared folder in VirtualBox: `C:\VMShare` → `VMShare`
- [ ] Set shared folder as **Auto-mount** and **Make Permanent**
- [ ] Map shared folder to Z: drive in Windows guest

**PowerShell command inside guest**:
```powershell
# Map VBoxSvr shared folder to Z:
net use Z: \\vboxsvr\VMShare /persistent:yes
```

- [ ] Verify Z: drive is accessible: `dir Z:\`
- [ ] Test write permissions: `echo "test" > Z:\test.txt`
- [ ] Test read permissions: `Get-Content Z:\test.txt`
- [ ] Verify shared folder persists after reboot

## Testing Tools Installation

### 5. BootRacer (Boot Time Measurement)
- [ ] Download BootRacer from official website
- [ ] Install BootRacer on Win11 VM
- [ ] Run once to verify it works
- [ ] Configure to save results to Z:\data\boot-time\

**Note**: BootRacer should be installed on ALL 4 VM snapshots (baseline, AV-only, firewall-only, both)

### 6. WSL and Sysbench (System Benchmarks)
- [ ] Install WSL: `wsl --install` (as Administrator)
- [ ] Reboot if prompted
- [ ] Complete Ubuntu setup
- [ ] Update packages: `wsl -- sudo apt-get update`
- [ ] Install sysbench: `wsl -- sudo apt-get install -y sysbench`
- [ ] Verify installation: `wsl -- sysbench --version`

### 7. PowerShell Scripts Deployment
- [ ] Clone/copy project scripts to VM
- [ ] Place scripts in: `C:\IDSTesting\scripts\`
- [ ] Verify scripts exist:
  - `smb-copy-test.ps1`
  - `ftp-download-test.ps1`
  - `process-count-test.ps1`
  - `ram-startup-test.ps1`
  - `sysbench-wrapper.ps1`
- [ ] Test one script to verify it can write to Z: drive

### 8. AV-Bench Application Launch Script
- [ ] Copy AV-Bench folder to VM: `C:\IDSTesting\AV-Bench\`
- [ ] Verify script.ps1 exists and has $iterations = 5
- [ ] Run once to test: `cd C:\IDSTesting\AV-Bench; .\script.ps1`
- [ ] Confirm measurements.csv is created
- [ ] Configure script to save to Z:\data\app-launch\

## Data Collection Directories

### 9. Create Data Directory Structure on Z:
```powershell
# On guest VM, create directories on Z: drive
mkdir Z:\data\baseline
mkdir Z:\data\symantec
mkdir Z:\data\opnsense
mkdir Z:\data\both

# Create subdirectories for each test type
$configs = @("baseline", "symantec", "opnsense", "both")
foreach ($config in $configs) {
    mkdir "Z:\data\$config\smb-copy"
    mkdir "Z:\data\$config\ftp-download"
    mkdir "Z:\data\$config\process-count"
    mkdir "Z:\data\$config\ram-startup"
    mkdir "Z:\data\$config\boot-time"
    mkdir "Z:\data\$config\sysbench"
    mkdir "Z:\data\$config\app-launch"
}
```

- [ ] Verify all directories created
- [ ] Test write access to each directory

## Windows Configuration

### 10. Disable Sleep and Hibernate
```powershell
# Prevent VM from sleeping during long tests
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /change monitor-timeout-ac 0
```

- [ ] Sleep/hibernate disabled
- [ ] Power plan set to High Performance

### 11. Disable Windows Updates During Testing
- [ ] Open Windows Update settings
- [ ] Pause updates for maximum duration (5 weeks)
- [ ] Disable automatic restarts

### 12. Configure Startup Script for Data Collection
- [ ] Create startup script to log RAM and process count automatically
- [ ] Place script in Startup folder: `shell:startup`
- [ ] Configure script to write to Z: drive

## Verification Checklist

### Final Verification Before Testing
- [ ] Network connectivity to QNAP NAS confirmed (SMB)
- [ ] Network connectivity to DIGI Storage confirmed (FTP)
- [ ] Z: drive mapped and writable
- [ ] All testing tools installed (BootRacer, sysbench, scripts)
- [ ] Data directories created on Z:
- [ ] Power settings configured (no sleep/hibernate)
- [ ] Windows updates paused
- [ ] VM snapshot created with all tools installed

## Snapshot Strategy

### 13. Create Clean Tool Baseline
After completing all setup steps above:
- [ ] Shutdown VM gracefully
- [ ] Create snapshot: **"Baseline-NoIDS-WithTools"**
- [ ] Verify snapshot can be restored
- [ ] Document snapshot in VM_SETUP_GUIDE.md

**Note**: This snapshot includes all testing tools but NO antivirus or firewall.

### 14. Create Configuration-Specific Snapshots
From "Baseline-NoIDS-WithTools", create 4 variants:
1. [ ] **Baseline-NoIDS**: No AV, no firewall (already done)
2. [ ] **Symantec-Only**: Install Symantec, create snapshot
3. [ ] **OPNsense-Only**: Install firewall, create snapshot
4. [ ] **Both**: Install Symantec + firewall, create snapshot

## Troubleshooting

### Common Issues

**Issue**: Shared folder not accessible  
**Solution**: Reinstall Guest Additions, check VBoxManage list, remount

**Issue**: WSL fails to install  
**Solution**: Enable virtualization in BIOS, run as Administrator

**Issue**: BootRacer not recording boot times  
**Solution**: Run as Administrator, check Windows Event Viewer

**Issue**: Scripts can't write to Z:  
**Solution**: Check permissions, verify folder not read-only, restart VM

**Issue**: Network tests fail  
**Solution**: Verify Bridged adapter, check firewall rules (Windows Firewall in baseline should allow SMB/FTP)

## Installation via CLI

### Symantec Installation (CLI)
```powershell
# If installer supports silent install:
.\SymantecEndpointProtection.exe /quiet /norestart
```
Check Symantec documentation for exact silent install parameters.

### Firewall Installation (CLI)
```powershell
# For Windows Firewall (built-in), enable via CLI:
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Configure specific rules as needed
New-NetFirewallRule -DisplayName "Allow SMB" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow
New-NetFirewallRule -DisplayName "Allow FTP" -Direction Outbound -Protocol TCP -LocalPort 21 -Action Allow
```

### BootRacer Installation (CLI)
```powershell
# If installer supports silent install:
.\bootracer_setup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
```

## Guest Setup Completion

Once all items checked:
- [ ] VM is ready for baseline testing (Phase 1)
- [ ] All 4 snapshots created and verified
- [ ] Shared folder Z: working correctly
- [ ] Data collection directories exist
- [ ] Testing tools functional

**Status**: Ready to begin measurements  
**Next Step**: See tasks.md Phase 1 - Baseline Measurements
