# VM Guest Setup Requirements

**VM Name**: Win11 (VirtualBox)  
**Status**: ✅ Clean baseline snapshot available  
**Network**: FTP configured via FileZilla (DIGI), SMB mapped to 192.168.50.99/Public/Test  
**Shared Folder**: C:\VMShare on host mapped to Z: on guest  
**Data Location**: All test data in C:\VMShare for host/guest accessibility  
**Updated**: 2026-01-16 16:25 UTC

## Already Configured

✅ **OS**: Windows 11 (up to date)  
✅ **BootRacer**: Pre-installed and ready for boot time measurements  
✅ **Clean Snapshot**: Available with name "Win11" for baseline testing  
✅ **FTP**: Configured via FileZilla for DIGI Storage access  
✅ **SMB Network Drive**: Mapped to 192.168.50.99/Public/Test  
✅ **Shared Folder**: C:\VMShare (host) mapped to Z: (guest)  
✅ **Test Scripts**: All 5 measurement scripts created in C:\VMShare\scripts\  
✅ **App Launch Script**: script.ps1 already configured with 5 iterations

## Required Software Installations

### Antivirus
- [ ] **Symantec Endpoint Protection** (for AV-only and Both configurations)
  - Installation method: Download from Symantec website or use installer
  - CLI installation possible: `SymantecEndpointProtection.exe /s /v"/qn"` (if silent installer available)

### Firewall
- [ ] **OPNsense** or **Windows Firewall** (for Firewall-only and Both configurations)
  - OPNsense: Typically router/appliance-based (may use Windows Firewall as alternative)
  - Alternative: Use built-in Windows Firewall with advanced rules via PowerShell
  - CLI configuration for Windows Firewall: `Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True`

## Required Network Configuration

### Shared Folder Mapping
✅ **Configured**
  - **Host**: `C:\VMShare` (all test data stored here)
  - **Guest**: `Z:` drive (mapped via VirtualBox shared folders)
  - **Purpose**: Automated data collection from tests accessible to both host and guest
  - **Status**: VirtualBox shared folder set up and functional

### Network Access
- [ ] **VirtualBox Network**: Bridged Adapter mode
  - Purpose: Access local network and QNAP NAS
  - Settings → Network → Adapter 1 → Attached to: Bridged Adapter

✅ **SMB Connection**: QNAP NAS at 192.168.50.99/Public/Test (already mapped via SMB)
  - Test: `Test-NetConnection -ComputerName 192.168.50.99 -Port 445`
  - Network drive ready for testing

✅ **FTP Connection**: DIGI Storage (already configured via FileZilla)
  - FTP client configured and tested
  - Remote server accessible for download testing

## Required Test Tools

✅ **BootRacer**: Already pre-installed for boot time measurement (Criterion A)  
✅ **script.ps1**: App launch script already available with 5 iterations (Criterion D - 75 apps × 5 iterations = 375 total)  
✅ **PowerShell test scripts**: All created in C:\VMShare\scripts\
  - ✅ boot-time-test.ps1
  - ✅ ram-startup-test.ps1
  - ✅ process-count-test.ps1
  - ✅ smb-copy-test.ps1
  - ✅ ftp-download-test.ps1

## Data Collection Folders

All data stored in C:\VMShare on host (mapped to Z: on guest):
```powershell
# Create folder structure on Z: drive (guest) or C:\VMShare (host)
New-Item -ItemType Directory -Path "Z:\data\baseline" -Force
New-Item -ItemType Directory -Path "Z:\data\symantec" -Force
New-Item -ItemType Directory -Path "Z:\data\firewall" -Force
New-Item -ItemType Directory -Path "Z:\data\both" -Force

# Subdirectories for each criterion (A-F)
$configs = @("baseline", "symantec", "firewall", "both")
foreach ($config in $configs) {
    New-Item -ItemType Directory -Path "Z:\data\$config\boot-time" -Force
    New-Item -ItemType Directory -Path "Z:\data\$config\ram-usage" -Force
    New-Item -ItemType Directory -Path "Z:\data\$config\process-count" -Force
    New-Item -ItemType Directory -Path "Z:\data\$config\app-launch" -Force
    New-Item -ItemType Directory -Path "Z:\data\$config\smb-transfer" -Force
    New-Item -ItemType Directory -Path "Z:\data\$config\ftp-download" -Force
}
```

**Note**: All test results automatically saved to Z:\data\ persist in C:\VMShare on host, accessible even after VM snapshots are restored.

## Snapshot Strategy

1. **Baseline-NoIDS**: ✅ Clean Windows 11 (current snapshot "Win11")
2. **Symantec-Only**: Restore baseline → Install Symantec → Create snapshot
3. **Firewall-Only**: Restore baseline → Install firewall (OPNsense or Windows Firewall) → Create snapshot
4. **Both**: Restore baseline → Install both Symantec and firewall → Create snapshot

## Testing Workflow

For each configuration:
1. Restore appropriate snapshot
2. Boot VM and verify software status (AV/firewall active or not)
3. Run all 6 test criteria (5 iterations each, 75 apps × 5 for app launch = 375 total)
4. Results automatically save to Z:\data\{config}\ (persists in C:\VMShare on host)
5. Shutdown VM
6. Data already accessible from host in C:\VMShare for analysis

## CLI Installation Commands

### Symantec (if silent CLI installer available)
```cmd
SymantecEndpointProtection.exe /s /v"/qn"
```

### VirtualBox Shared Folder (configured from host)
```powershell
VBoxManage sharedfolder add "Win11" --name "VMShare" --hostpath "C:\VMShare" --automount
```
✅ Already configured

### Windows Firewall Configuration (alternative to OPNsense)
```powershell
# Enable Windows Firewall on all profiles
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Verify status
Get-NetFirewallProfile | Select Name, Enabled
```

## Verification Checklist

Before starting tests:
- [x] Shared folder Z: accessible from guest (mapped to C:\VMShare on host)
- [x] SMB connection to 192.168.50.99/Public/Test working
- [x] FTP connection to DIGI Storage working (via FileZilla)
- [x] BootRacer pre-installed and functional
- [x] script.ps1 ready (75 apps × 5 iterations = 375 total)
- [x] All 5 test scripts created in C:\VMShare\scripts\
- [ ] All data folders created on Z: (or C:\VMShare on host)
- [ ] All 4 snapshots created and verified
- [ ] Windows Firewall can be enabled via PowerShell for firewall testing

**Test Criteria Summary**:
- **A**: Boot time (BootRacer)
- **B**: RAM usage at startup
- **C**: Process count at startup
- **D**: App launch performance (AV-Bench/script.ps1, 375 total launches)
- **E**: SMB network transfer (1GB to QNAP)
- **F**: FTP download (100MB from DIGI)

---

**Next Steps**: See `specs/001-av-benchmark/tasks.md` for detailed task breakdown.
