# Project Status & Next Steps

**Project**: IDS Impact Analysis Research  
**Updated**: 2026-01-16 17:40 UTC  
**Deadline**: 2026-01-23 21:00

---

## ✅ Completed Updates

### 1. Specifications Updated
- **Removed**: Criterion g (sysbench) - not supported on Windows
- **Reordered criteria**: 
  - a = Boot Time (was e)
  - b = RAM Usage (was d)
  - c = Process Count (unchanged)
  - d = Remote Download/FTP (was b)
  - e = Local Network/SMB (was a)
  - f = Application Launch (unchanged bonus criterion)
- **Corrected iteration counts**: 5 iterations × 75 apps = 375 total launches (was incorrectly listed as 125)
- **Added network details**: SMB to 192.168.50.99:/Public/Test via 1Gbit LAN, FTP to DIGI Storage
- **Added shared folder requirement**: C:\VMShare on host → Z: drive in guest

### 2. Bibliography Enhanced
- ✅ Added 3 testing methodology references (Tom's Hardware & AnandTech) to paper.bib
- ✅ References are properly formatted in BibTeX
- ✅ Ready to cite in LaTeX paper

### 3. LaTeX Template Verified
- ✅ LNCS template compiles successfully
- ✅ PDF generation working (paper.pdf created successfully)
- ✅ No missing packages detected

### 4. Documentation Created
- ✅ **VM_GUEST_SETUP_REQUIREMENTS.md**: Complete setup guide for WIN11 VM
  - Shared folder mapping instructions
  - Network share configuration (QNAP NAS)
  - FTP setup (DIGI Storage)
  - Verification scripts included

---

## 📊 Project Scope Summary

### Test Matrix
- **Configurations**: 4 (Baseline, Symantec, OPNsense, Both)
- **Criteria**: 6 (a-f, removed g)
- **Iterations**: 5 per test
- **Total test runs**: 120 (was 140)

### Criteria Breakdown
| ID | Criterion | Tool/Method | Iterations | Total per Config |
|----|-----------|-------------|------------|------------------|
| a  | Boot Time | BootRacer | 5 boots | 5 measurements |
| b  | RAM Usage | perfmon | 5 boots | 5 measurements |
| c  | Process Count | Get-Process | 5 boots | 5 measurements |
| d  | Remote Download | FTP script | 5 iterations | 5 measurements |
| e  | Local Network Copy | SMB script | 5 iterations | 5 measurements |
| f  | App Launch | AV-Bench/script.ps1 | 5 iterations | 5 measurements |

**Per configuration**: 30 measurements  
**Total measurements**: 120 (4 configs × 30)

### Application Launch Test Details
- **Per iteration**: 75 apps (25 calc, 25 mspaint, 25 notepad)
- **Iterations**: 5
- **Total launches per config**: 375 apps
- **Total launches project-wide**: 1,500 apps (4 configs × 375)

---

## 🎯 Next Steps

### Immediate Action Items

#### 1. VM Guest Setup (Priority: HIGH)
**Status**: ⏳ Pending configuration

**Required on WIN11 VM** (See: VM_GUEST_SETUP_REQUIREMENTS.md):
- [ ] Map VirtualBox shared folder to Z: drive
  ```powershell
  net use Z: \\VBOXSVR\VMShare /persistent:yes
  ```
- [ ] Map QNAP NAS to network drive (e.g., N:)
  ```powershell
  net use N: \\192.168.50.99\Public\Test /persistent:yes
  ```
- [ ] Test FTP connection to DIGI Storage
- [ ] Verify BootRacer is installed and working
- [ ] Run setup verification script

**Verification Command**:
```powershell
# Run this in VM to verify setup
Test-Path Z:\ ; Test-Path N:\ ; Get-Process | Measure-Object
```

#### 2. Host Setup (Priority: HIGH)
**Status**: ⏳ Pending

**Required on Host Computer**:
- [ ] Create shared folder: `C:\VMShare`
- [ ] Configure VirtualBox shared folders for WIN11 VM
- [ ] Create data directory structure:
  ```powershell
  mkdir C:\VMShare\data\baseline, C:\VMShare\data\symantec, 
        C:\VMShare\data\opnsense, C:\VMShare\data\both
  ```

#### 3. Test Scripts Creation (Priority: HIGH)
**Status**: ⏳ Pending

**Scripts to Create** (See: specs/001-av-benchmark/tasks.md for details):
- [ ] `smb-copy-test.ps1` - SMB network copy benchmark
- [ ] `ftp-download-test.ps1` - FTP download speed test
- [ ] `process-count-test.ps1` - Process counting at startup
- [ ] `ram-startup-test.ps1` - RAM measurement at startup

**Script Requirements**:
- Accept parameters: `-ConfigName`, `-Iterations`
- Output to CSV: `Z:\data\{config}\{criterion}-{config}.csv`
- Include timestamps and iteration numbers
- Handle errors gracefully

#### 4. Test Data Preparation (Priority: MEDIUM)
**Status**: ⏳ Pending

- [ ] Create 1GB test folder on QNAP NAS (192.168.50.99:/Public/Test)
- [ ] Upload 100MB test file to DIGI Storage (FTP)
- [ ] Verify network connectivity (1Gbit LAN)

---

## 📋 Testing Workflow

### Phase 0: Setup (Day 1)
1. Configure WIN11 VM (shared folders, network, drives)
2. Create test scripts
3. Prepare test data (1GB folder, 100MB file)
4. Verify all tools working

### Phase 1: Baseline (Days 1-2)
1. Restore "Baseline-NoIDS" snapshot
2. Run all 6 criteria tests (5 iterations each)
3. Collect data to Z:\data\baseline\
4. Verify variance <10%

### Phase 2: Symantec (Days 3-4)
1. Install Symantec Endpoint Protection
2. Create "Symantec-Only" snapshot
3. Run all 6 criteria tests (5 iterations each)
4. Collect data to Z:\data\symantec\

### Phase 3: OPNsense (Days 5-6)
1. Install OPNsense/firewall
2. Create "OPNsense-Only" snapshot
3. Run all 6 criteria tests (5 iterations each)
4. Collect data to Z:\data\opnsense\

### Phase 4: Combined (Day 7)
1. Install both Symantec + OPNsense
2. Create "Symantec-OPNsense-Both" snapshot
3. Run all 6 criteria tests (5 iterations each)
4. Collect data to Z:\data\both\

### Phase 5: Analysis (Days 8-9)
1. Import all 24 CSV files
2. Calculate overhead percentages
3. Generate 6 comparative graphs
4. Verify statistical significance

### Phase 6: Writing (Days 10-13)
1. Write LaTeX paper (all sections)
2. Insert graphs and tables
3. Add bibliography references
4. Compile and proofread

### Phase 7: Submission (Day 14)
1. Final plagiarism check (TurnItIn ≤7%)
2. Package PDF + LaTeX sources
3. Submit before deadline

---

## 🔧 Technical Details

### Network Configuration
- **VM Network Adapter**: Bridged mode
- **QNAP NAS**: 192.168.50.99:/Public/Test (SMB)
- **DIGI Storage**: FTP (IP/hostname as configured)
- **Local LAN**: 1 Gigabit connection

### Data Collection Flow
```
WIN11 VM (Guest)
  ├─ Run test script
  ├─ Generate measurements
  └─ Save to Z:\data\{config}\*.csv
         ↓
Host Computer (C:\VMShare)
  ├─ Automatically receives data
  ├─ Data persists across VM snapshots
  └─ Ready for analysis
```

### File Structure
```
C:\VMShare\                          (Host)
├── scripts\                         (Test scripts)
│   ├── smb-copy-test.ps1
│   ├── ftp-download-test.ps1
│   ├── process-count-test.ps1
│   └── ram-startup-test.ps1
├── data\                            (Measurement results)
│   ├── baseline\
│   │   ├── boot-time-baseline.csv
│   │   ├── ram-startup-baseline.csv
│   │   ├── process-count-baseline.csv
│   │   ├── ftp-download-baseline.csv
│   │   ├── smb-copy-baseline.csv
│   │   └── app-launch-baseline.csv
│   ├── symantec\
│   ├── opnsense\
│   └── both\
└── AV-Bench\
    ├── script.ps1                   (Already exists, configured for 5 iterations)
    └── measurements.csv

Z:\                                  (Mapped in VM)
└── (Same as C:\VMShare on host)
```

---

## 📚 Key Documents

- **Specification**: `specs/001-av-benchmark/spec.md`
- **Implementation Plan**: `specs/001-av-benchmark/plan.md`
- **Task List**: `specs/001-av-benchmark/tasks.md`
- **VM Setup Guide**: `VM_GUEST_SETUP_REQUIREMENTS.md`
- **Bibliography**: `BIBLIOGRAPHY_REFERENCES.md`
- **LaTeX Template**: `lncs-enhanced-main/paper.tex`

---

## ⚠️ Important Notes

### Removed Items
- ~~Criterion g (sysbench)~~ - Removed due to Windows incompatibility
- Total criteria reduced from 7 to 6
- Total test runs reduced from 140 to 120

### Corrected Information
- Application launch: **75 apps per iteration**, not 125
- Total app launches: **375 per config** (5 × 75)
- Script already configured for 5 iterations (no modification needed)

### Critical Requirements
- [ ] Shared folder MUST be configured for data collection
- [ ] QNAP NAS MUST be accessible on 192.168.50.99
- [ ] FTP to DIGI Storage MUST be configured
- [ ] All measurements MUST show variance <10%
- [ ] Bibliography MUST include 3 Tom's Hardware/AnandTech references ✅
- [ ] Plagiarism check MUST be ≤7%
- [ ] Paper MUST be ≥7 pages

---

## 🚀 Recommended First Steps

1. **Create C:\VMShare folder on host**
   ```powershell
   mkdir C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\VMShare
   mkdir C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\VMShare\data\baseline
   mkdir C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\VMShare\data\symantec
   mkdir C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\VMShare\data\opnsense
   mkdir C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\VMShare\data\both
   mkdir C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\VMShare\scripts
   ```

2. **Configure VirtualBox shared folder**
   - VirtualBox Manager → WIN11 VM → Settings → Shared Folders
   - Add: Folder Path = `C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\VMShare`
   - Folder Name = `VMShare`
   - Enable: Auto-mount + Make Permanent

3. **Boot VM and map Z: drive**
   ```powershell
   # Run in VM as Administrator
   net use Z: \\VBOXSVR\VMShare /persistent:yes
   ```

4. **Verify setup**
   ```powershell
   # Run in VM
   Test-Path Z:\
   "test" | Out-File Z:\test.txt
   Get-Content Z:\test.txt
   ```

5. **Create test scripts** (See specs/001-av-benchmark/tasks.md, TASK-010)

---

**Status**: Ready to begin Phase 0 setup  
**Next Action**: Configure shared folder and test scripts  
**Time Remaining**: 7 days to deadline
