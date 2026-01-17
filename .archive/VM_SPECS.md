# WIN11 VM Specifications

**Platform**: Oracle VirtualBox
**VM Name**: WIN11
**UUID**: a5339315-24b3-4095-9807-0ab5ca680101

## Hardware Configuration

- **OS Type**: Windows 11 (64-bit)
- **CPU Cores**: 4
- **RAM**: 8192 MB (8 GB)
- **Video RAM**: 128 MB
- **Storage Controller**: SATA (Intel AHCI)
- **Network**: (to be documented from testing)

## Snapshot Information

- **Current Snapshot**: "Clean"
- **Status**: ✓ Clean baseline exists
- **Description**: Windows 11 fully updated, no antivirus or firewall

## Snapshots to Create

Based on the IDS impact analysis requirements:

1. **Baseline-NoIDS** (rename "Clean" snapshot)
   - Clean Windows 11, no IDS software
   
2. **Symantec-Only**
   - Symantec Endpoint Protection installed and active
   
3. **OPNsense-Only** (or Windows Firewall equivalent)
   - Firewall installed and active
   
4. **Symantec-OPNsense-Both**
   - Both Symantec and firewall active

## VirtualBox Commands

List VMs:
```
VBoxManage list vms
```

Get VM info:
```
VBoxManage showvminfo "WIN11"
```

List snapshots:
```
VBoxManage snapshot "WIN11" list
```

Take snapshot:
```
VBoxManage snapshot "WIN11" take "Baseline-NoIDS" --description "Clean baseline"
```

Restore snapshot:
```
VBoxManage snapshot "WIN11" restore "Baseline-NoIDS"
```

## Methodology Section Data

For the LaTeX paper, document as:

"Testing was conducted on an Oracle VirtualBox virtual machine (v7.x) 
configured with Windows 11 (64-bit), 4 CPU cores, and 8 GB RAM. The VM 
utilized a SATA storage controller with Intel AHCI. Four distinct 
configurations were established using VirtualBox snapshots: (1) Baseline 
with no IDS software, (2) Symantec Endpoint Protection only, (3) OPNsense 
firewall only, and (4) both Symantec and OPNsense active simultaneously."

## Testing Notes

- VM located at: C:\Users\lizzardkink\VirtualBox VMs\WIN11\
- Clean snapshot verified: ✓
- Ready for configuration setup: ✓
- Adequate resources for testing: ✓ (4 cores, 8GB RAM sufficient)

**Date Documented**: 2026-01-16
