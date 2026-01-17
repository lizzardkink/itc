# Current Project Status

**Project**: IDS Impact Analysis Research  
**Date**: 2026-01-16 17:47 UTC  
**Deadline**: 2026-01-23 21:00  
**Days Remaining**: 7 days

---

## ✅ What's Complete

### Specifications & Documentation
- ✅ Specification document updated (specs/001-av-benchmark/spec.md)
- ✅ Implementation plan updated (specs/001-av-benchmark/plan.md)
- ✅ Task list prepared (specs/001-av-benchmark/tasks.md)
- ✅ VM guest setup guide created (VM_GUEST_SETUP_REQUIREMENTS.md)
- ✅ Next steps document created (NEXT_STEPS_UPDATED.md)

### Bibliography & LaTeX
- ✅ LaTeX template verified (compiles successfully)
- ✅ 3 Tom's Hardware/AnandTech references added to paper.bib
- ✅ PDF generation working (lncs-enhanced-main/paper.pdf)

### Key Changes Applied
- ✅ Removed criterion g (sysbench) - Windows incompatible
- ✅ Reordered criteria (a=Boot, b=RAM, c=Process, d=FTP, e=SMB, f=AppLaunch)
- ✅ Fixed app launch count: 75 per iteration, 375 total per config
- ✅ Added shared folder requirement (C:\VMShare → Z:)
- ✅ Added network details (SMB to 192.168.50.99, FTP to DIGI)

### VM Configuration Status
- ✅ WIN11 VM exists in VirtualBox
- ✅ Shared folder already configured (C:\VMShare → 'VMShare')
- ⚠️ VM is powered off (expected)

---

## ⏳ What Needs to Be Done

### Immediate Setup Required (Day 1)

#### 1. Create C:\VMShare Directory Structure
**Status**: Not created yet

```powershell
# Run on host computer
mkdir C:\VMShare
mkdir C:\VMShare\data\baseline
mkdir C:\VMShare\data\symantec
mkdir C:\VMShare\data\opnsense
mkdir C:\VMShare\data\both
mkdir C:\VMShare\scripts
```

#### 2. Configure VM Network to Bridged Mode
**Current**: NAT mode  
**Required**: Bridged Adapter for QNAP NAS access

**Steps**:
1. VirtualBox Manager → WIN11 VM → Settings → Network
2. Adapter 1 → Attached to: **Bridged Adapter**
3. Select physical Ethernet/Wi-Fi adapter
4. Click OK

**CLI Alternative**:
```powershell
# Power off VM first
VBoxManage modifyvm "WIN11" --nic1 bridged --bridgeadapter1 "Your-Network-Adapter-Name"
```

#### 3. Create Baseline Snapshot
**Current**: No snapshots exist  
**Required**: "Baseline-NoIDS" snapshot (clean OS, no AV/firewall)

**Steps**:
1. Start WIN11 VM
2. Verify Windows is up to date
3. Verify no antivirus or firewall installed
4. Shut down VM cleanly
5. VBoxManage snapshot "WIN11" take "Baseline-NoIDS" --description "Clean Windows 11, OS updated, no AV/firewall"

#### 4. Guest VM Configuration (Inside WIN11 VM)
Once VM is booted, run as Administrator:

```powershell
# Map shared folder to Z: drive
net use Z: \\VBOXSVR\VMShare /persistent:yes

# Verify
Test-Path Z:\

# Map QNAP NAS (requires VM in Bridged mode)
net use N: \\192.168.50.99\Public\Test /persistent:yes

# Verify network access
Test-NetConnection -ComputerName 192.168.50.99 -Port 445
```

#### 5. Create Test Scripts
**Location**: C:\VMShare\scripts\

**Required Scripts**:
1. `smb-copy-test.ps1` - SMB network copy benchmark
2. `ftp-download-test.ps1` - FTP download speed test
3. `process-count-test.ps1` - Process counting at startup
4. `ram-startup-test.ps1` - RAM measurement at startup

**Specifications**:
- Accept parameters: `-ConfigName`, `-Iterations` (default 5)
- Output CSV to: `Z:\data\{config}\{criterion}-{config}.csv`
- Include: Index, Timestamp, Measurement, Unit columns
- Handle errors gracefully

#### 6. Prepare Test Data
**QNAP NAS** (192.168.50.99:/Public/Test):
- Create 1GB test folder (multiple files)
- Verify accessible via SMB from VM

**DIGI Storage** (FTP):
- Upload 100MB test file
- Verify FTP credentials
- Test download from VM

---

## 📊 Updated Project Scope

### Test Matrix
- **Configurations**: 4 (Baseline, Symantec, OPNsense, Both)
- **Criteria**: 6 (removed sysbench)
- **Iterations**: 5 per test
- **Total test runs**: 120 (reduced from 140)

### Criteria Details
| ID | Criterion | Tool | Reordered From |
|----|-----------|------|----------------|
| a  | Boot Time | BootRacer | Was criterion e |
| b  | RAM Usage | perfmon | Was criterion d |
| c  | Process Count | Get-Process | Unchanged |
| d  | Remote Download | FTP script | Was criterion b |
| e  | Local Network | SMB script | Was criterion a |
| f  | App Launch | AV-Bench/script.ps1 | Unchanged (bonus) |
| ~~g~~ | ~~System Bench~~ | ~~sysbench~~ | **REMOVED** |

### Application Launch Details
- **Per iteration**: 75 apps (25 calc + 25 paint + 25 notepad)
- **Script iterations**: 5 (already configured in AV-Bench/script.ps1)
- **Total per config**: 375 app launches
- **Project total**: 1,500 app launches

---

## 🎯 Next Actions (Priority Order)

### High Priority (Must Do Today)
1. [ ] Create C:\VMShare directory structure
2. [ ] Change VM network to Bridged mode
3. [ ] Boot VM and configure guest (Z: and N: drives)
4. [ ] Create baseline "Baseline-NoIDS" snapshot
5. [ ] Create 4 test scripts (smb, ftp, process, ram)

### Medium Priority (Day 1-2)
6. [ ] Prepare 1GB test folder on QNAP NAS
7. [ ] Upload 100MB file to DIGI Storage FTP
8. [ ] Test all scripts on baseline configuration
9. [ ] Run baseline measurements (6 criteria × 5 iterations)

### Lower Priority (Day 3+)
10. [ ] Install Symantec on clean baseline
11. [ ] Run Symantec configuration tests
12. [ ] Install OPNsense/firewall
13. [ ] Run firewall configuration tests
14. [ ] Install both (combined configuration)
15. [ ] Run combined tests

---

## 📁 Current File Structure

### On Host (C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC)
```
ItC/
├── specs/
│   └── 001-av-benchmark/
│       ├── spec.md                    ✅ Updated
│       ├── plan.md                    ✅ Updated
│       └── tasks.md                   ✅ Ready
├── lncs-enhanced-main/
│   ├── paper.tex                      ✅ Compiles
│   ├── paper.bib                      ✅ References added
│   └── paper.pdf                      ✅ Generated
├── AV-Bench/
│   └── script.ps1                     ✅ Already configured (5 iterations)
├── VM_GUEST_SETUP_REQUIREMENTS.md     ✅ Complete guide
├── NEXT_STEPS_UPDATED.md              ✅ Detailed next steps
├── CURRENT_STATUS.md                  ✅ This file
└── BIBLIOGRAPHY_REFERENCES.md         ✅ Reference list

VMShare/                                ⏳ Needs to be created
├── scripts/                            ⏳ Needs 4 scripts
│   ├── smb-copy-test.ps1
│   ├── ftp-download-test.ps1
│   ├── process-count-test.ps1
│   └── ram-startup-test.ps1
└── data/                               ⏳ Empty, ready for measurements
    ├── baseline/
    ├── symantec/
    ├── opnsense/
    └── both/
```

---

## 🚀 Quick Start Commands

### On Host Computer
```powershell
# 1. Create directory structure
mkdir C:\VMShare
mkdir C:\VMShare\data\baseline, C:\VMShare\data\symantec, C:\VMShare\data\opnsense, C:\VMShare\data\both
mkdir C:\VMShare\scripts

# 2. Verify shared folder configured
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" showvminfo "WIN11" | Select-String "VMShare"

# 3. Change network to Bridged (if needed)
# Get your adapter name first:
Get-NetAdapter | Select-Object Name, Status, LinkSpeed

# Then apply:
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "WIN11" --nic1 bridged --bridgeadapter1 "YOUR-ADAPTER-NAME"
```

### Inside WIN11 VM (After Booting)
```powershell
# Run as Administrator

# 1. Map shared folder
net use Z: \\VBOXSVR\VMShare /persistent:yes

# 2. Verify
Test-Path Z:\
"test" | Out-File Z:\test.txt
Get-Content Z:\test.txt

# 3. Map QNAP NAS (once in Bridged mode)
net use N: \\192.168.50.99\Public\Test /persistent:yes

# 4. Verify network
ipconfig
Test-NetConnection -ComputerName 192.168.50.99 -Port 445
```

---

## ⚠️ Known Issues & Solutions

### Issue: Shared folder already configured
**Status**: ✅ Good! C:\VMShare → 'VMShare' already configured in VirtualBox  
**Action**: Just need to create C:\VMShare directory on host

### Issue: VM has no snapshots
**Status**: ⚠️ Need to create "Baseline-NoIDS" snapshot  
**Action**: Boot VM, verify clean state, create snapshot

### Issue: Network in NAT mode
**Status**: ⚠️ Needs Bridged mode for QNAP access  
**Action**: Change to Bridged Adapter in VM settings

### Issue: Test scripts don't exist
**Status**: ⏳ Need to be created  
**Action**: Use templates from tasks.md (TASK-010) or adapt from existing scripts

---

## 📞 Resources

- **Specification**: specs/001-av-benchmark/spec.md
- **Implementation Plan**: specs/001-av-benchmark/plan.md
- **Task Checklist**: specs/001-av-benchmark/tasks.md  
- **VM Setup Guide**: VM_GUEST_SETUP_REQUIREMENTS.md
- **Bibliography**: BIBLIOGRAPHY_REFERENCES.md, lncs-enhanced-main/paper.bib

---

## ✨ Summary

**Ready to proceed**: Yes, with setup tasks  
**Blockers**: None  
**Estimated setup time**: 2-3 hours  
**Time to first measurements**: Day 1-2  
**Deadline pressure**: 7 days - adequate if started today

**Recommended action**: Begin with creating C:\VMShare directory and changing VM network to Bridged mode, then proceed with guest configuration.

---

**Last Updated**: 2026-01-16 17:47 UTC  
**Next Review**: After Phase 0 setup complete
