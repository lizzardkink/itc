# Next Steps: IDS Impact Analysis Project

**Date**: 2026-01-16  
**Deadline**: 2026-01-23, 21:00 (7 days remaining)  
**Status**: Ready to begin testing

## Immediate Next Steps (Priority Order)

### 1. ✅ COMPLETED: Project Setup & Specifications
- [x] Specifications documented (spec.md, plan.md, tasks.md)
- [x] Criteria reordered (A=Boot, B=RAM, C=Process, D=SMB, E=FTP, F=AppLaunch, G=Sysbench-optional)
- [x] Network configuration clarified (192.168.50.99:/Public/Test via SMB, DIGI Storage via FTP)
- [x] Shared folder strategy defined (C:\VMShare → Z: drive in guest)
- [x] Bibliography references identified (Tom's Hardware, AnandTech)
- [x] Application launch corrected (125 instances per iteration = 5 iterations × 25 apps)
- [x] LaTeX template verified (compiles successfully)

### 2. 🔄 IN PROGRESS: Guest VM Configuration

You mentioned:
- VM "Win11" is already set up with VirtualBox
- Clean snapshot exists with OS up to date
- No antivirus or firewall installed yet
- BootRacer is already installed
- FTP configured via FileZilla (DIGI)
- SMB network folder mapped (192.168.50.99:/Public/Test)

**Remaining Guest Setup Tasks**:

#### A. Configure Shared Folder for Data Collection
```powershell
# On Host (Windows PowerShell as Administrator)
mkdir C:\VMShare
New-SmbShare -Name "VMShare" -Path "C:\VMShare" -FullAccess Everyone

# In VirtualBox Manager
# Settings → Shared Folders → Add:
#   Folder Path: C:\VMShare
#   Folder Name: VMShare
#   Auto-mount: Yes
#   Mount point: Z:
```

#### B. Inside Guest VM
```powershell
# Verify Z: drive is mapped
Test-Path Z:\

# Create data directory structure
mkdir Z:\data\baseline, Z:\data\symantec, Z:\data\opnsense, Z:\data\both

# Set PowerShell execution policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify network access
Test-NetConnection -ComputerName 192.168.50.99 -Port 445
Test-Path N:\  # Should show network share contents
```

#### C. Copy Testing Scripts to Guest
Transfer these from host to guest:
- `AV-Bench\script.ps1` → Already in guest? Verify location.
- Create process/RAM/network test scripts (see VM_GUEST_SETUP_CHECKLIST.md)

### 3. 📝 CREATE TEST SCRIPTS

We have 5 PowerShell scripts to create. You can install through CLI or create manually:

#### Option A: Install via CLI (if scripts exist in repo)
```powershell
# On host, copy scripts to shared folder
Copy-Item -Path "scripts\*.ps1" -Destination "C:\VMShare\scripts\" -Recurse
```

#### Option B: Create Scripts Manually

Based on your existing scripts in `scripts/` directory, we need:

1. **smb-copy-test.ps1** - Measures SMB network copy speed
2. **ftp-download-test.ps1** - Measures FTP download speed  
3. **process-count-test.ps1** - Counts running processes
4. **ram-startup-test.ps1** - Measures RAM usage
5. **sysbench-wrapper.ps1** - (Optional) Wraps sysbench commands

Check if these already exist:
```powershell
Get-ChildItem -Path "C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\scripts" -Filter "*.ps1"
```

### 4. 🧪 RUN BASELINE TESTS (Configuration 1: No IDS)

**Estimated Time**: 4-6 hours

Before installing any antivirus or firewall, collect baseline measurements:

```powershell
# Inside Guest VM (Win11)

# Test A: Boot Time (5 reboots)
# BootRacer runs automatically, export results to Z:\data\baseline\

# Test B: RAM Usage at Startup (5 iterations)
.\scripts\ram-startup-test.ps1 -ConfigName "baseline" -Iterations 5

# Test C: Process Count (5 iterations)
.\scripts\process-count-test.ps1 -ConfigName "baseline" -Iterations 5

# Test D: SMB Copy Speed (5 iterations)
.\scripts\smb-copy-test.ps1 -ConfigName "baseline" -Iterations 5

# Test E: FTP Download Speed (5 iterations)
.\scripts\ftp-download-test.ps1 -ConfigName "baseline" -Iterations 5

# Test F: Application Launch (5 iterations)
cd C:\path\to\AV-Bench
.\script.ps1
# Then copy measurements.csv to Z:\data\baseline\app-launch-baseline.csv

# Test G (Optional): Sysbench (if installed)
.\scripts\sysbench-wrapper.ps1 -ConfigName "baseline" -Iterations 5
```

**Expected Output**: 6-7 CSV files in Z:\data\baseline\ (visible from host at C:\VMShare\data\baseline\)

### 5. 📸 CREATE VM SNAPSHOTS

After baseline testing complete:

```powershell
# In VirtualBox Manager (or via VBoxManage)
VBoxManage snapshot "Win11" take "Baseline-NoIDS" --description "Clean Windows 11, BootRacer installed, no AV/Firewall, baseline tests completed"
```

### 6. 🛡️ INSTALL SYMANTEC (Configuration 2)

**Estimated Time**: 6-8 hours

```powershell
# Restore baseline snapshot
VBoxManage snapshot "Win11" restore "Baseline-NoIDS"

# Start VM, install Symantec Endpoint Protection
# Update virus definitions
# Verify real-time protection enabled

# Create snapshot
VBoxManage snapshot "Win11" take "Symantec-Only"

# Run all 6-7 tests again (same as baseline)
# Results go to Z:\data\symantec\
```

### 7. 🔥 INSTALL FIREWALL (Configuration 3: OPNsense)

**Estimated Time**: 6-8 hours

**Note**: OPNsense is typically a standalone firewall appliance. For Windows, you'll likely use:
- **Windows Firewall with Advanced Security** (built-in)
- Or a client component if Symantec/OPNsense integration exists

```powershell
# Restore baseline snapshot
VBoxManage snapshot "Win11" restore "Baseline-NoIDS"

# Configure Windows Firewall or install OPNsense client
# Enable firewall rules
# Verify firewall active

# Create snapshot
VBoxManage snapshot "Win11" take "OPNsense-Only"

# Run all 6-7 tests again
# Results go to Z:\data\opnsense\
```

### 8. 🛡️🔥 INSTALL BOTH (Configuration 4)

**Estimated Time**: 6-8 hours

```powershell
# Restore baseline snapshot
VBoxManage snapshot "Win11" restore "Baseline-NoIDS"

# Install Symantec
# Configure Windows Firewall
# Verify both active

# Create snapshot
VBoxManage snapshot "Win11" take "Symantec-OPNsense-Both"

# Run all 6-7 tests again
# Results go to Z:\data\both\
```

### 9. 📊 DATA ANALYSIS

**Estimated Time**: 6-8 hours

After all testing complete, on host machine:

```powershell
# Check all data collected
Get-ChildItem -Path "C:\VMShare\data" -Recurse -Filter "*.csv"

# Expected: 24-28 CSV files total (4 configs × 6-7 criteria)
```

Import data into Excel/Python/R and:
1. Calculate averages for each criterion
2. Calculate percentage overhead vs baseline
3. Generate 6-7 comparative graphs
4. Export graphs to `lncs-enhanced-main\figures\`

### 10. ✍️ WRITE LATEX PAPER

**Estimated Time**: 16-20 hours over 4 days

```latex
% In lncs-enhanced-main/paper.tex

% Structure:
% 1. Abstract (150-250 words)
% 2. Introduction (1-1.5 pages)
% 3. Related Work (1 page) - Add bibliography references
% 4. Methodology (2-2.5 pages)
% 5. Results (2 pages) - Include tables and graphs
% 6. Discussion (1.5-2 pages)
% 7. Conclusion (0.5-1 page)
% 8. References (using paper.bib)
```

Add bibliography entries from BIBLIOGRAPHY_REFERENCES.md to paper.bib:
```bash
# Compile with bibliography
lualatex paper.tex
bibtex paper
lualatex paper.tex
lualatex paper.tex
```

### 11. ✅ FINAL CHECKS

- [ ] PDF is 7+ pages
- [ ] All 6 criteria documented (7 if sysbench included)
- [ ] All graphs included
- [ ] 3 references from Tom's Hardware/AnandTech
- [ ] Run plagiarism check (must be ≤7%)
- [ ] Proofread for grammar/clarity

### 12. 📤 SUBMIT

**Deadline**: 2026-01-23, 21:00

Submit to e-learning system:
- paper.pdf
- Complete LaTeX sources (paper.tex, paper.bib, figures/)

## Timeline Summary

| Days | Phase | Status |
|------|-------|--------|
| Day 1 | Guest setup + Baseline tests | **→ START HERE** |
| Day 2 | Baseline completion | Pending |
| Day 3-4 | Symantec configuration & tests | Pending |
| Day 5-6 | Firewall configuration & tests | Pending |
| Day 7 | Combined configuration & tests | Pending |
| Day 8-9 | Data analysis & graphs | Pending |
| Day 10-13 | LaTeX paper writing | Pending |
| Day 14 | Final review & submission | Pending |

## Quick Reference: What You've Told Me

✅ **Already Done**:
- VM "Win11" set up in VirtualBox
- Clean snapshot with OS up to date
- BootRacer installed
- FTP configured via FileZilla (DIGI)
- SMB mapped: 192.168.50.99:/Public/Test

📝 **Need to Do**:
- Map C:\VMShare → Z: drive in guest
- Create/copy test scripts to guest
- Create data directory structure (Z:\data\...)
- Run baseline tests (6 criteria, 5 iterations each)
- Install Symantec, test, snapshot
- Install firewall, test, snapshot
- Install both, test, snapshot
- Analyze data, generate graphs
- Write LaTeX paper
- Submit before deadline

## Resources

- **VM Setup**: VM_GUEST_SETUP_CHECKLIST.md (comprehensive checklist)
- **Bibliography**: BIBLIOGRAPHY_REFERENCES.md (Tom's Hardware, AnandTech references)
- **Specifications**: specs/001-av-benchmark/spec.md
- **Tasks**: specs/001-av-benchmark/tasks.md
- **Plan**: specs/001-av-benchmark/plan.md

## Questions?

**Q: Can we install through CLI?**  
A: Yes! Use PowerShell to automate as much as possible. See scripts in `scripts/` directory.

**Q: What needs to be set up on the guest?**  
A: See VM_GUEST_SETUP_CHECKLIST.md for complete list. Key items:
1. Map Z: drive to shared folder
2. Copy test scripts
3. Set PowerShell execution policy
4. Verify network access (SMB + FTP)

**Q: How will we gather measurements after running scripts on the VM?**  
A: All scripts save to Z: drive (mapped to C:\VMShare on host), so data automatically appears on host machine.

**Q: What about the 75 launches?**  
A: Corrected to 125 instances per iteration (5 iterations × 25 apps = 125 per iteration, 625 total launches across 5 iterations).

## Current Status: Ready to Begin Testing! 🚀

**Your next immediate action**: 
1. Configure shared folder (C:\VMShare → Z: in guest)
2. Create data directories on Z: drive
3. Copy/create test scripts in guest VM
4. Start baseline testing

Good luck! 🎯

**Last Updated**: 2026-01-16 15:34 UTC
