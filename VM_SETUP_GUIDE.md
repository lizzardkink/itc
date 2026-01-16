# VM Setup Guide for IDS Impact Analysis

**VM Platform**: VirtualBox  
**VM Name**: Win11  
**Status**: ✓ Clean baseline snapshot exists  
**Date**: 2026-01-16

## Current Configuration

### Baseline Snapshot
- **Name**: (Current clean snapshot in VirtualBox)
- **OS**: Windows 11 (fully updated)
- **State**: No antivirus or firewall installed
- **Purpose**: Starting point for all 4 test configurations

## Required Snapshots

You need to create 4 snapshots from the baseline:

### 1. Baseline-NoIDS (Already Have This)
- **Source**: Current clean snapshot
- **Software**: None (clean Windows 11)
- **Purpose**: Baseline measurements for criteria a-e + sysbench
- **Action**: Rename current snapshot to "Baseline-NoIDS"

### 2. Symantec-Only
- **Source**: Restore from Baseline-NoIDS
- **Install**: Symantec Endpoint Protection or Symantec Antivirus
- **Configuration**: Enable real-time protection, update definitions
- **Verification**: Confirm antivirus is active (check system tray, services)
- **Action**: Create snapshot after installation and verification

### 3. OPNsense-Only
- **Source**: Restore from Baseline-NoIDS
- **Install**: OPNsense (Note: This is typically a network appliance)
- **Alternative**: If OPNsense can't run on Windows, consider:
  - Windows Firewall with advanced security configured
  - Document as "Windows Firewall (OPNsense-equivalent)" in paper
  - Or run OPNsense in separate VM and route Win11 traffic through it
- **Configuration**: Enable firewall rules, logging
- **Verification**: Confirm firewall is active
- **Action**: Create snapshot after installation and verification

### 4. Symantec-OPNsense-Both
- **Source**: Restore from Baseline-NoIDS
- **Install**: Both Symantec + OPNsense (in order)
- **Configuration**: Enable both with standard settings
- **Verification**: Confirm both are active simultaneously
- **Action**: Create snapshot after installation and verification

## VM Specifications to Document

For the methodology section of your paper, document these from VirtualBox:

```powershell
# Get VM info from VirtualBox CLI
VBoxManage showvminfo "Win11" --machinereadable
```

Required specifications:
- **CPU Cores**: (e.g., 2 cores, 4 cores)
- **RAM**: (e.g., 4GB, 8GB)
- **Disk Size**: (e.g., 50GB)
- **Network Adapter**: (e.g., NAT, Bridged)
- **VirtualBox Version**: (e.g., 7.0.x)

## Snapshot Management Workflow

### Creating Snapshots

```powershell
# Take snapshot via VirtualBox CLI
VBoxManage snapshot "Win11" take "Baseline-NoIDS" --description "Clean Windows 11, no IDS"
VBoxManage snapshot "Win11" take "Symantec-Only" --description "Symantec AV installed"
VBoxManage snapshot "Win11" take "OPNsense-Only" --description "OPNsense/FW installed"
VBoxManage snapshot "Win11" take "Symantec-OPNsense-Both" --description "Both AV and FW"
```

Or use VirtualBox GUI:
1. Select VM "Win11"
2. Click "Snapshots" button
3. Click "Take" icon
4. Name snapshot appropriately
5. Add description

### Restoring Snapshots

```powershell
# Restore specific snapshot
VBoxManage snapshot "Win11" restore "Baseline-NoIDS"
```

Or in GUI:
1. Select snapshot from list
2. Click "Restore" icon
3. Confirm restoration

## Testing Workflow

For each benchmark test:

1. **Restore appropriate snapshot**
   ```powershell
   VBoxManage snapshot "Win11" restore "Baseline-NoIDS"
   ```

2. **Start VM**
   ```powershell
   VBoxManage startvm "Win11"
   ```

3. **Wait for boot to complete**

4. **Run benchmark** (BootRacer, process count, RAM check, sysbench, etc.)

5. **Record measurements** to CSV

6. **Shutdown VM**
   ```powershell
   VBoxManage controlvm "Win11" poweroff
   ```

7. **Repeat for other configurations**

## VirtualBox Commands Reference

### List all snapshots
```powershell
VBoxManage snapshot "Win11" list
```

### Get VM state
```powershell
VBoxManage showvminfo "Win11" | Select-String "State"
```

### Export VM specifications
```powershell
VBoxManage showvminfo "Win11" > vm-specs.txt
```

## Network Configuration for Tests

### For Criterion (a): 1GB Folder Copy

You need network connectivity to another device:

**Option 1**: Bridged Adapter
- Set VM network to "Bridged Adapter"
- VM gets IP on your local network
- Can access shared folders on other devices

**Option 2**: Host-Only Adapter + Shared Folder
- Create VirtualBox shared folder
- Test folder copy within VirtualBox environment

### For Criterion (b): 100MB Remote Download

Ensure VM has internet access:
- NAT network mode (default) works
- Or Bridged if your network allows

## Pre-Testing Checklist

Before starting measurements:

- [ ] Clean baseline snapshot exists and is verified
- [ ] Symantec is downloaded and ready to install
- [ ] OPNsense strategy is determined (separate VM or Windows FW)
- [ ] BootRacer or equivalent is downloaded
- [ ] sysbench is available (WSL setup or Windows build)
- [ ] 1GB test folder is prepared
- [ ] Remote 100MB test file is accessible
- [ ] Network connectivity is verified
- [ ] Measurement scripts are ready
- [ ] CSV files for data collection are prepared
- [ ] VM specifications are documented

## Snapshot Naming Convention

Use clear, consistent names:
- `Baseline-NoIDS` - Clean system
- `Symantec-Only` - AV only
- `OPNsense-Only` - Firewall only
- `Symantec-OPNsense-Both` - Both installed

## Troubleshooting

### Snapshot restore fails
- Ensure VM is powered off first
- Check disk space on host
- Verify snapshot integrity

### Network not working after restore
- Restart VM network: `VBoxManage controlvm "Win11" nic1 null; VBoxManage controlvm "Win11" nic1 nat`
- Check VirtualBox network settings

### Performance is inconsistent
- Disable host sleep/hibernation during tests
- Close other applications on host
- Ensure VM has adequate resources allocated

## Next Steps

1. Document current VM specifications (CPU, RAM, disk)
2. Rename existing snapshot to "Baseline-NoIDS"
3. Create testing sequence plan
4. Download required tools (Symantec, BootRacer, sysbench)
5. Begin measurements with Baseline-NoIDS configuration
6. Install and test each subsequent configuration
7. Collect all data in structured CSV format
8. Analyze and generate graphs for LaTeX paper
