# Next Steps - IDS Performance Testing Project

**Date**: January 16, 2026  
**Deadline**: January 23, 2026, 21:00  
**Days Remaining**: 7

## ✅ Completed

1. **Specifications finalized**
   - Antivirus: Symantec Endpoint Protection
   - Firewall: OPNsense
   - All criteria defined and reordered (A-G)
   - Shared folder mapping: C:\VMShare → Z:
   - Bibliography with 3 testing methodology references

2. **LaTeX template verified**
   - LNCS template compiles successfully
   - All packages installed
   - PDF generation working

3. **Host preparation**
   - C:\VMShare folder structure created
   - Data directories ready (baseline, symantec, opnsense, both)

4. **Documentation complete**
   - VM_GUEST_REQUIREMENTS.md created
   - All setup procedures documented

## 🔄 Current Phase: Phase 0 - Environment Setup

### Step 1: Configure VirtualBox Shared Folder (5 minutes)

**Action**: Add shared folder to Win11 VM in VirtualBox

**Instructions**:
1. Open VirtualBox Manager
2. Select "Win11" VM (do NOT start it yet)
3. Click Settings → Shared Folders
4. Click "Add new shared folder" icon (folder with +)
5. Configure:
   - **Folder Path**: C:\VMShare
   - **Folder Name**: VMShare
   - ☑ Auto-mount
   - ☑ Make Permanent
   - **Mount point**: (leave blank, will assign Z: manually in guest)
6. Click OK to save

**Verification**: Setting will show "VMShare → C:\VMShare" in Shared Folders list

---

### Step 2: Boot VM and Verify Guest Additions (10 minutes)

**Action**: Ensure VirtualBox Guest Additions are installed for shared folder support

**Instructions**:
1. Start Win11 VM
2. Check if Guest Additions are installed:
   ```powershell
   Get-Service -Name VBoxService
   ```
   - If service exists → Guest Additions installed ✅
   - If not found → Install Guest Additions:
     - VM menu: Devices → Insert Guest Additions CD Image
     - Open CD drive in File Explorer
     - Run VBoxWindowsAdditions.exe
     - Reboot VM after installation

**Verification**: VBoxService should be running

---

### Step 3: Map Shared Folder to Z: Drive (2 minutes)

**Action**: Create persistent drive mapping in guest VM

**Instructions** (in Win11 VM PowerShell):
```powershell
# Map Z: drive to shared folder
net use Z: \\vboxsvr\VMShare /persistent:yes

# Verify mapping
Get-PSDrive Z

# Test read/write access
echo "Test connection" > Z:\test.txt
Get-Content Z:\test.txt
```

**Verification**: 
- Z: drive appears in File Explorer
- Test file readable from both host (C:\VMShare\test.txt) and guest (Z:\test.txt)

---

### Step 4: Install WSL and sysbench (20 minutes)

**Action**: Install Windows Subsystem for Linux with sysbench for Criterion F testing

**Instructions** (in Win11 VM PowerShell as Administrator):
```powershell
# Install WSL with Ubuntu
wsl --install

# System will require reboot - reboot now
```

**After reboot**, continue:
```powershell
# First WSL launch will prompt for username/password - create account
wsl

# In WSL terminal, install sysbench:
sudo apt-get update
sudo apt-get install -y sysbench

# Exit WSL
exit

# Verify installation from PowerShell:
wsl sysbench --version
```

**Expected Output**: `sysbench 1.0.20` (or similar version)

---

### Step 5: Test Network Connectivity (10 minutes)

**Action**: Verify VM can access QNAP NAS and DIGI Storage

#### Test QNAP NAS (SMB - Criterion D)

```powershell
# Replace [QNAP-IP] with actual QNAP IP address
Test-NetConnection -ComputerName [QNAP-IP] -Port 445

# Try to access share
dir \\[QNAP-IP]\[share-name]

# If successful, locate the 1GB test folder
# If not created yet, you'll need to create it on QNAP
```

**Required**: 1GB test folder on QNAP NAS for recursive copy testing

#### Test DIGI Storage (FTP - Criterion E)

```powershell
# Replace [DIGI-SERVER] with actual DIGI Storage server address
Test-NetConnection -ComputerName [DIGI-SERVER] -Port 21

# Test FTP login (replace credentials)
$client = New-Object System.Net.WebClient
$client.Credentials = New-Object System.Net.NetworkCredential("username", "password")
$client.DownloadString("ftp://[DIGI-SERVER]/")
```

**Required**: 100MB test file on DIGI Storage for download testing

---

### Step 6: Verify BootRacer Configuration (5 minutes)

**Action**: Ensure BootRacer exports data to Z: drive

**Instructions**:
1. Open BootRacer
2. Check settings/preferences
3. Set export path to: `Z:\data\baseline\boot-time-baseline.csv`
4. Enable automatic export after each boot (if available)

**Note**: If BootRacer doesn't support direct CSV export to Z:, you'll need to manually copy data after each test run

---

### Step 7: Copy Test Scripts to Guest (5 minutes)

**Action**: Prepare PowerShell scripts on guest for automated testing

**Instructions** (in Win11 VM):
```powershell
# Create scripts directory
New-Item -ItemType Directory -Path C:\scripts -Force

# Enable script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Copy scripts from host repository to guest
# (These scripts will be created in the next phase)
# For now, verify you can access the host's repo through Z: drive
```

**Note**: Test scripts will be created in next phase based on NETWORK_TEST_CONFIG.md and REMOTE_DOWNLOAD_CONFIG.md templates

---

### Step 8: Create Baseline Snapshot (2 minutes)

**Action**: Create clean baseline snapshot for testing

**Instructions**:
1. Verify all setup complete:
   - ✅ Z: drive mapped and working
   - ✅ WSL + sysbench installed
   - ✅ BootRacer configured
   - ✅ Network connectivity verified
   - ✅ No antivirus running (Windows Defender disabled)
   - ✅ No firewall enabled
2. Shutdown VM cleanly
3. In VirtualBox, create snapshot: "Baseline-NoIDS"
4. Add description: "Clean Windows 11, fully updated, all tools installed, no AV/firewall, ready for testing"

---

## 📋 Phase 0 Checklist

Before proceeding to Phase 1 (Baseline Testing), verify:

- [ ] VirtualBox shared folder configured (VMShare → C:\VMShare)
- [ ] Guest Additions installed in Win11 VM
- [ ] Z: drive mapped to \\vboxsvr\VMShare
- [ ] Can write to Z: from guest and read from C:\VMShare on host
- [ ] WSL installed and functional
- [ ] sysbench installed: `wsl sysbench --version` works
- [ ] QNAP NAS accessible via SMB (port 445)
- [ ] 1GB test folder exists on QNAP
- [ ] DIGI Storage accessible via FTP (port 21)
- [ ] 100MB test file exists on DIGI Storage
- [ ] BootRacer configured for data export
- [ ] AV-Bench script tested and working
- [ ] Baseline-NoIDS snapshot created
- [ ] Can restore snapshot and verify all tools still work

---

## 🚀 Next Phase: Phase 1 - Baseline Measurements

**Estimated Time**: 6-8 hours

Once Phase 0 checklist is complete, you'll begin collecting baseline measurements:

1. Boot time (BootRacer) - 5 boots
2. RAM at startup - 5 boots
3. Process count - 5 boots
4. SMB copy speed (1GB from QNAP) - 5 iterations
5. FTP download (100MB from DIGI) - 5 iterations
6. sysbench CPU/memory/disk - 5 iterations
7. Application launch (AV-Bench) - 5 iterations (already configured)

All results saved to: `Z:\data\baseline\*.csv`

---

## ⏱️ Timeline Overview

| Phase | Duration | Status |
|-------|----------|--------|
| Phase 0: Setup | 1 hour | **← YOU ARE HERE** |
| Phase 1: Baseline | 6-8 hours | Next |
| Phase 2: Symantec | 8-10 hours | Pending |
| Phase 3: OPNsense | 8-10 hours | Pending |
| Phase 4: Combined | 8-10 hours | Pending |
| Phase 5: Analysis | 6-8 hours | Pending |
| Phase 6: Writing | 16-20 hours | Pending |
| Phase 7: Submission | 2-4 hours | Pending |

**Total**: ~60-80 hours over 7 days

---

## 📞 Quick Reference

### Key File Locations

**Host**:
- Specs: `C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\specs\001-av-benchmark\`
- Shared folder: `C:\VMShare\`
- LaTeX paper: `C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\lncs-enhanced-main\`

**Guest (Win11 VM)**:
- Mapped drive: `Z:\`
- Scripts: `C:\scripts\`
- AV-Bench: `C:\Users\[username]\ItC\AV-Bench\`
- BootRacer: Program Files

### Important Commands

**Check shared folder**:
```powershell
Get-PSDrive Z
dir Z:\
```

**Test sysbench**:
```powershell
wsl sysbench cpu --time=10 run
```

**Run AV-Bench test**:
```powershell
cd C:\Users\[username]\ItC\AV-Bench
.\script.ps1
# Copy results: Copy-Item measurements.csv Z:\data\baseline\app-launch-baseline.csv
```

---

## 💡 Tips

1. **Take your time with setup** - A properly configured environment prevents headaches later
2. **Test everything twice** - Verify shared folder survives VM reboot
3. **Document IP addresses** - Write down QNAP IP and DIGI server address
4. **Keep credentials handy** - You'll need FTP login multiple times
5. **Snapshot often** - Create snapshots after each successful configuration step
6. **Monitor variance** - If any test shows >10% variance, investigate before continuing

---

## ❓ Troubleshooting

See `VM_GUEST_REQUIREMENTS.md` for detailed troubleshooting steps.

**Most common issues**:
- Shared folder not visible → Reinstall Guest Additions
- Z: drive not mapping → Use `net use Z: \\vboxsvr\VMShare`
- WSL not installing → Ensure virtualization enabled in VM settings
- Network tests failing → Check VM network adapter is in Bridged mode

---

**Ready to begin? Start with Step 1: Configure VirtualBox Shared Folder**
