# Tasks: IDS Impact Analysis Research

**Feature**: `001-av-benchmark` | **Date**: 2026-01-16 15:49 UTC  
**Status**: Ready to start | **Deadline**: 23 Jan 2026, 21:00

**Test Criteria (Reordered)**:
- **Criterion A**: OS boot time (BootRacer)
- **Criterion B**: RAM at startup
- **Criterion C**: Process count at startup
- **Criterion D**: Application launch performance (AV-Bench/script.ps1, 75 apps × 5 iterations = 375 total)
- **Criterion E**: Local network SMB copy (1GB to 192.168.50.99/Public/Test)
- **Criterion F**: Remote FTP download (100MB from DIGI Storage)

**Configuration**:
- Antivirus: Symantec
- Firewall: OPNsense (or Windows Firewall as alternative)
- VM: Win11 (VirtualBox), BootRacer pre-installed
- Network: SMB to QNAP 192.168.50.99/Public/Test, FTP to DIGI Storage (configured via FileZilla)
- Shared folder: Host C:\VMShare → Guest Z: (all data in C:\VMShare for host/guest access)
- Iterations: 5 per test (total 375 app launches for Criterion D across 5 iterations)

**Current Status**: ✅ Environment configured | ✅ Test scripts created | ✅ Remote GUI control implemented | 🚀 **NEXT: Begin baseline measurements**

**Completed Setup**:
- [x] VM baseline snapshot available
- [x] BootRacer pre-installed
- [x] Shared folder configured (C:\VMShare → Z:)
- [x] SMB network drive mapped (192.168.50.99/Public/Test)
- [x] FTP configured (DIGI Storage via FileZilla)
- [x] Data folder structure created in C:\VMShare\data\
- [x] Test scripts created in C:\VMShare\scripts\
- [x] PowerShell remoting configured (NAT port forwarding, 127.0.0.1:5985)
- [x] Auto-login configured for admin user
- [x] Remote GUI control solution implemented (file-based signaling)

**Immediate Next Steps** (in order):
1. ✅ **TASK-009**: Create data folder structure - COMPLETE
2. ✅ **TASK-010**: Create/modify PowerShell test scripts - COMPLETE
3. ✅ **TASK-010C**: Implement remote GUI application control - COMPLETE
4. 🔄 **TASK-010B**: Gather system information for LaTeX paper - **NEXT ACTION**
5. 🔄 **TASK-011**: Begin baseline measurements

**Where Measurements Are Captured**:
All test measurements are saved as CSV files to **C:\VMShare\data\** on the host computer:
- Boot time → C:\VMShare\data\{config}\boot-time-{config}.csv
- RAM usage → C:\VMShare\data\{config}\ram-startup-{config}.csv  
- Process count → C:\VMShare\data\{config}\process-count-{config}.csv
- App launch → C:\VMShare\data\{config}\app-launch-{config}.csv
- SMB transfer → C:\VMShare\data\{config}\smb-copy-{config}.csv
- FTP download → C:\VMShare\data\{config}\ftp-download-{config}.csv

(Where {config} = baseline, symantec, opnsense, or both)

📂 Folders created:
  - C:\VMShare\data\baseline\
  - C:\VMShare\data\symantec\
  - C:\VMShare\data\opnsense\
  - C:\VMShare\data\both\

## Task Organization

Tasks are organized by phase and prioritized. Each task includes acceptance criteria and estimated time.

---

## Phase 0: Environment Setup (Day 1) - 4-6 hours

### TASK-001: Configure VM Baseline Snapshot
**Priority**: P0 (Blocker)  
**Estimated Time**: 30 minutes  
**Dependencies**: None

**Description**: Rename existing 'Clean' VM snapshot to 'Baseline-NoIDS' for clear identification.

**Steps**:
1. Open VirtualBox
2. Select WIN11 VM
3. Go to Snapshots tab
4. Rename 'Clean' → 'Baseline-NoIDS'
5. Add description: "Windows 11 updated, no AV/firewall"

**Acceptance Criteria**:
- [ ] Snapshot renamed to 'Baseline-NoIDS'
- [ ] Description added and saved
- [ ] Snapshot can be restored successfully

**Command**:
```powershell
VBoxManage snapshot "WIN11" list
```

---

### TASK-002: Configure VM Network to Bridged Mode
**Priority**: P0 (Blocker)  
**Estimated Time**: 15 minutes  
**Dependencies**: None

**Description**: Set WIN11 VM network adapter to Bridged mode for local network access to QNAP NAS.

**Steps**:
1. Open VirtualBox
2. Select WIN11 VM → Settings
3. Network → Adapter 1
4. Attached to: Bridged Adapter
5. Name: Select your physical Ethernet adapter
6. Save settings

**Acceptance Criteria**:
- [ ] VM network set to Bridged Adapter
- [ ] Correct physical adapter selected
- [ ] Settings saved

**Verification**:
```powershell
VBoxManage showvminfo "WIN11" | Select-String "NIC"
```

---

### TASK-003: Verify QNAP NAS Connectivity
**Priority**: P0 (Blocker)  
**Estimated Time**: 15 minutes  
**Dependencies**: TASK-002

**Description**: Verify WIN11 VM can access QNAP NAS via SMB protocol.

**Steps**:
1. Start WIN11 VM
2. Open PowerShell
3. Test ping: `ping QNAP-IP`
4. Test SMB: `dir \\QNAP-IP\share`
5. Map network drive if needed

**Acceptance Criteria**:
- [ ] Ping to QNAP succeeds
- [ ] SMB share accessible
- [ ] Can browse QNAP folders

**Test Command**:
```powershell
Test-NetConnection -ComputerName QNAP-IP -Port 445
```

---

### TASK-004: Create 1GB Test Folder on QNAP
**Priority**: P0 (Blocker)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-003

**Description**: Create test folder with 1GB of data on QNAP NAS for SMB copy benchmarks.

**Steps**:
1. Access QNAP NAS
2. Create folder: `ids-test-data`
3. Generate 10x 100MB files using provided script
4. Verify total size ≥1GB

**Acceptance Criteria**:
- [ ] Test folder created on QNAP
- [ ] Contains ≥1GB data
- [ ] Accessible from WIN11 VM

**Script**: See `NETWORK_TEST_CONFIG.md` section "Creating Test Data"

---

### TASK-005: Verify DIGI Storage FTP Access
**Priority**: P0 (Blocker)  
**Estimated Time**: 20 minutes  
**Dependencies**: None

**Description**: Verify WIN11 VM can connect to DIGI Storage server via FTP.

**Steps**:
1. Start WIN11 VM
2. Open PowerShell
3. Test connectivity: `Test-NetConnection -ComputerName digi-storage-server -Port 21`
4. Test FTP login with credentials
5. List files

**Acceptance Criteria**:
- [ ] FTP port 21 accessible
- [ ] Login successful with credentials
- [ ] Can list remote files

**Test Command**:
```powershell
$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential("username", "password")
$webclient.DownloadString("ftp://digi-storage-server/")
```

---

### TASK-006: Upload 100MB Test File to DIGI Storage
**Priority**: P0 (Blocker)  
**Estimated Time**: 20 minutes  
**Dependencies**: TASK-005

**Description**: Create and upload 100MB test file to DIGI Storage for remote download benchmarks.

**Steps**:
1. Generate 100MB file locally
2. Upload to DIGI Storage via FTP
3. Verify file exists and size correct
4. Test download once

**Acceptance Criteria**:
- [ ] 100MB file on DIGI Storage
- [ ] Accessible via FTP
- [ ] Can be downloaded successfully

**Script**: See `REMOTE_DOWNLOAD_CONFIG.md` section "Test File Preparation"

---



### TASK-008: Download and Install BootRacer
**Priority**: P0 (Blocker)  
**Estimated Time**: 15 minutes  
**Dependencies**: None

**Description**: Download BootRacer or equivalent tool for boot time measurement (criterion e).

**Steps**:
1. Download BootRacer from official website
2. Install on WIN11 VM
3. Run once to test
4. Note installation for all configurations

**Acceptance Criteria**:
- [ ] BootRacer installed
- [ ] Tool runs successfully
- [ ] Boot time measurement verified

**Alternative**: Windows built-in tool or PowerShell event log analysis

---

### TASK-009: Create Data Directory Structure
**Priority**: P1 (High)  
**Estimated Time**: 10 minutes  
**Dependencies**: None
**Status**: ✅ **COMPLETE**

**Description**: Create directory structure for storing measurement CSV files.

**Steps**:
1. Navigate to project root
2. Create directories: `C:\VMShare\data\baseline`, `C:\VMShare\data\symantec`, `C:\VMShare\data\opnsense`, `C:\VMShare\data\both`
3. Verify structure

**Acceptance Criteria**:
- [x] All data directories created
- [x] Structure accessible from host
- [x] Accessible from VM guest as Z:\data\

**Command**:
```powershell
mkdir C:\VMShare\data\baseline, C:\VMShare\data\symantec, C:\VMShare\data\opnsense, C:\VMShare\data\both
```

**Completed**: 2026-01-16 16:22 UTC

---

### TASK-010: Create PowerShell Test Scripts
**Priority**: P1 (High)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-009
**Status**: ✅ **COMPLETE**

**Description**: Create PowerShell scripts for automated testing and modify existing app launch script.

**Scripts Created**:
1. `scripts/SMB-Copy-Test.ps1`
2. `scripts/FTP-Download-Test.ps1`
3. `scripts/Automated-Boot-Cycle-With-BootRacer.ps1`
4. `scripts/Run-AllTests-SingleIteration.ps1`
5. `scripts/Invoke-VMCommand.ps1` - Remote command execution helper
6. `scripts/Test-VMConnection.ps1` - Connection testing
7. `scripts/Analyze-AllData.ps1` - Data analysis automation

**Acceptance Criteria**:
- [x] All scripts created in scripts\ folder
- [x] Scripts include parameter handling for Config and Iteration
- [x] Scripts export to CSV in C:\VMShare\data\
- [x] Scripts ready to run remotely via PowerShell remoting
- [x] Remote execution tested and verified

**Completed**: 2026-01-16 16:25 UTC

---

### TASK-010C: Implement Remote GUI Application Control
**Priority**: P0 (Blocker)  
**Estimated Time**: 3 hours  
**Dependencies**: TASK-010
**Status**: ✅ **COMPLETE**

**Description**: Solve the Session 0 vs Session 1 problem for remote GUI app launching. PowerShell remoting runs in Session 0 (no GUI access), requiring a helper script in Session 1 (desktop) to launch visible applications.

**Problem Identified**:
- PowerShell remoting runs in Session 0 (non-interactive)
- GUI apps launched from remoting have no visible windows
- Paint, Notepad, Calculator need Session 1 (desktop) to be visible

**Solution Implemented**:
- File-based signaling between Session 0 (remoting) and Session 1 (desktop)
- Helper script (GUI-App-Launcher-Helper.ps1) runs in desktop session
- Monitors Z:\gui_trigger.txt for launch/close requests
- Communicates status via Z:\gui_processed.txt

**Files Created**:
1. `scripts/Invoke-RemoteGUIApp.ps1` - Remote control interface
2. `scripts/Test-RemoteGUIApps.ps1` - Testing/research script  
3. `scripts/Test-AppLaunch-Remote.ps1` - Updated app launch test using remote GUI
4. `analysis/Remote-GUI-Solution.md` - Complete technical documentation
5. `Z:\GUI-App-Launcher-Helper.ps1` - Helper deployed on VM

**Acceptance Criteria**:
- [x] Helper script created and deployed to VM
- [x] Remote control script created (Invoke-RemoteGUIApp.ps1)
- [x] Tested launching Paint, Notepad, Calculator remotely
- [x] Tested closing all instances remotely
- [x] Apps launch in Session 1 with visible windows
- [x] File-based signaling works reliably
- [x] Complete documentation created

**Usage**:
```powershell
# Launch apps remotely with visible windows
.\Invoke-RemoteGUIApp.ps1 -AppName mspaint -Action Launch -Count 25
.\Invoke-RemoteGUIApp.ps1 -AppName notepad -Action Launch -Count 25
.\Invoke-RemoteGUIApp.ps1 -AppName calc -Action Launch -Count 25

# Close all instances
.\Invoke-RemoteGUIApp.ps1 -AppName mspaint -Action CloseAll
```

**Setup Required**:
- Helper must be running on VM desktop: `& 'Z:\GUI-App-Launcher-Helper.ps1'`
- Auto-login configured so VM boots to desktop automatically
- Z: drive accessible from both Session 0 and Session 1

**Completed**: 2026-01-16 20:55 UTC

---

### TASK-010B: Gather System Information for LaTeX Paper
**Priority**: P1 (High)  
**Estimated Time**: 10 minutes  
**Dependencies**: None
**Status**: 📝 **TODO**

**Description**: Run PowerShell script in VM guest to gather exact system specifications for inclusion in the LaTeX paper methodology section.

**Steps**:
1. Boot Win11 VM
2. Open PowerShell in VM
3. Run: `Z:\get-system-info.ps1`
4. Verify output saved to `Z:\system-info.txt`
5. Copy information to update LaTeX paper

**Information to Gather**:
- Exact Windows 11 version and build number
- CPU model, cores, and logical processors
- RAM amount (GB)
- Disk size (GB)

**Acceptance Criteria**:
- [ ] Script executed successfully
- [ ] System info file created at C:\VMShare\system-info.txt
- [ ] Information ready for LaTeX paper update

**Next Step**: Update paper.tex with actual system specifications (replace XXXXX placeholders)

---

## Phase 1: Baseline Measurements (Days 1-2) - 6-8 hours

### TASK-011: Run Baseline SMB Copy Test
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-001, TASK-004, TASK-010

**Description**: Measure SMB folder copy speed from QNAP NAS (criterion a) on baseline configuration.

**Steps**:
1. Restore Baseline-NoIDS snapshot
2. Start WIN11 VM
3. Run: `.\scripts\smb-copy-test.ps1 -Iterations 5`
4. Save results: `data\baseline\smb-copy-baseline.csv`
5. Verify variance <10%

**Acceptance Criteria**:
- [ ] 5 iterations completed
- [ ] CSV file generated
- [ ] Variance <10%
- [ ] Average speed documented

---

### TASK-012: Run Baseline FTP Download Test
**Priority**: P0 (Blocker)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-001, TASK-006, TASK-010

**Description**: Measure FTP download speed from DIGI Storage (criterion b) on baseline configuration.

**Steps**:
1. Ensure VM still running (or restore snapshot)
2. Run: `.\scripts\ftp-download-test.ps1 -Iterations 5`
3. Save results: `data\baseline\ftp-download-baseline.csv`
4. Verify variance <10%

**Acceptance Criteria**:
- [ ] 5 iterations completed
- [ ] CSV file generated
- [ ] Variance <10%
- [ ] Average speed documented

---

### TASK-013: Measure Baseline Process Count
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-001, TASK-010

**Description**: Count Windows processes at startup (criterion c) on baseline configuration.

**Steps**:
1. Restore Baseline-NoIDS snapshot
2. Start VM and wait for full boot
3. Count processes: `Get-Process | Measure-Object`
4. Record count
5. Repeat 5 times (5 boots)
6. Save results: `data\baseline\process-count-baseline.csv`

**Acceptance Criteria**:
- [ ] 5 measurements taken
- [ ] CSV file generated
- [ ] Variance <10%
- [ ] Average count documented

---

### TASK-014: Measure Baseline RAM at Startup
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-001, TASK-010

**Description**: Measure RAM consumption at system startup (criterion d) on baseline configuration.

**Steps**:
1. Restore Baseline-NoIDS snapshot
2. Start VM and wait for full boot
3. Measure RAM: `Get-CimInstance Win32_OperatingSystem | Select FreePhysicalMemory, TotalVisibleMemorySize`
4. Calculate used RAM
5. Repeat 5 times (5 boots)
6. Save results: `data\baseline\ram-startup-baseline.csv`

**Acceptance Criteria**:
- [ ] 5 measurements taken
- [ ] CSV file generated
- [ ] Variance <10%
- [ ] Average RAM usage documented

---

### TASK-015: Measure Baseline Boot Time
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-001, TASK-008

**Description**: Measure OS boot time (criterion e) on baseline configuration using BootRacer.

**Steps**:
1. Restore Baseline-NoIDS snapshot
2. Start VM
3. Record BootRacer measurements
4. Repeat 5 times (5 boots)
5. Save results: `data\baseline\boot-time-baseline.csv`

**Acceptance Criteria**:
- [ ] 5 measurements taken
- [ ] CSV file generated
- [ ] Variance <10%
- [ ] Average boot time documented

---



### TASK-016: Run Baseline Application Launch Test
**Priority**: P0 (Blocker)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-001, TASK-010, TASK-010C

**Description**: Run application launch performance test (Criterion D) on baseline configuration using remote GUI control.

**Steps**:
1. Restore Baseline-NoIDS snapshot (if needed)
2. Start VM
3. Ensure GUI-App-Launcher-Helper.ps1 is running on VM desktop
4. Run from host: `.\scripts\Test-AppLaunch-Remote.ps1 -ConfigName baseline -Iterations 5`
5. Wait for 5 iterations to complete (~10-15 minutes)
6. Verify results saved to `C:\VMShare\data\baseline\app-launch-baseline.csv`

**Technical Details**:
- Uses Invoke-RemoteGUIApp.ps1 for remote GUI control
- Launches 75 apps per iteration (25 each: Calc, Notepad, Paint)
- File-based signaling between Session 0 (remoting) and Session 1 (desktop)
- Apps launch with visible windows in correct session
- Automatic cleanup after each iteration

**Acceptance Criteria**:
- [ ] Helper script running on VM desktop
- [ ] 5 iterations completed (75 apps × 5 = 375 total launches)
- [ ] Apps launch with visible windows (verified manually)
- [ ] CSV file generated at correct location
- [ ] Variance <10%
- [ ] Average time documented (expected: 8-20 seconds for 75 apps depending on launch method overhead)

**Note**: Remote GUI control adds small overhead (~200ms per app) due to file-based signaling, but ensures apps launch correctly in visible session.

---

### TASK-017: Verify Baseline Data Quality
**Priority**: P0 (Blocker)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-011 through TASK-016A

**Description**: Review all baseline measurements for completeness and consistency.

**Steps**:
1. Check all 6 CSV files exist (boot-time, ram-usage, process-count, app-launch, smb-transfer, ftp-download)
2. Verify 5 iterations in each file
3. Calculate variance for each criterion
4. Document any issues
5. Re-run tests if variance >10%

**Acceptance Criteria**:
- [ ] All 6 CSV files present
- [ ] All variances <10%
- [ ] Data ready for comparison

---

## Phase 2: Symantec Configuration (Days 3-4) - 8-10 hours

### TASK-018: Install Symantec Endpoint Protection
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-017

**Description**: Install Symantec antivirus on clean baseline and create snapshot.

**Steps**:
1. Restore Baseline-NoIDS snapshot
2. Start VM
3. Install Symantec Endpoint Protection
4. Update virus definitions
5. Verify real-time protection active
6. Shutdown VM
7. Create snapshot: 'Symantec-Only'

**Acceptance Criteria**:
- [ ] Symantec installed successfully
- [ ] Real-time protection enabled
- [ ] Definitions updated
- [ ] Snapshot created
- [ ] Snapshot can be restored

---

### TASK-019: Run Symantec Tests (All Criteria)
**Priority**: P0 (Blocker)  
**Estimated Time**: 5-6 hours  
**Dependencies**: TASK-018

**Description**: Run all 6 criteria tests on Symantec-Only configuration (5 iterations each).

**Steps**:
1. Restore Symantec-Only snapshot
2. Run boot time test (Criterion A) → `Z:\data\symantec\boot-time-symantec.csv`
3. Run RAM startup test (Criterion B) → `Z:\data\symantec\ram-startup-symantec.csv`
4. Run process count test (Criterion C) → `Z:\data\symantec\process-count-symantec.csv`
5. Run app launch test (Criterion D) → `Z:\data\symantec\app-launch-symantec.csv`
6. Run SMB copy test (Criterion E) → `Z:\data\symantec\smb-copy-symantec.csv`
7. Run FTP download test (Criterion F) → `Z:\data\symantec\ftp-download-symantec.csv`

**Acceptance Criteria**:
- [ ] All 6 criteria tested (5 iterations each)
- [ ] All CSV files generated in Z:\data\
- [ ] Variance <10% per criterion
- [ ] Data saved to symantec directory

---

### TASK-020: Calculate Symantec Overhead
**Priority**: P1 (High)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-019

**Description**: Calculate percentage overhead for Symantec configuration vs baseline.

**Steps**:
1. Load baseline and Symantec CSV files from C:\VMShare\data\
2. Calculate average for each criterion
3. Calculate percentage overhead: `((IDS - Baseline) / Baseline) * 100`
4. Document results

**Acceptance Criteria**:
- [ ] Overhead calculated for all 6 criteria
- [ ] Results documented
- [ ] Overhead percentages reasonable (5-40%)

---

## Phase 3: OPNsense Configuration (Days 5-6) - 8-10 hours

### TASK-021: Install OPNsense/Firewall
**Priority**: P0 (Blocker)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-020

**Description**: Install firewall (OPNsense or Windows Firewall) on clean baseline and create snapshot.

**Steps**:
1. Restore Baseline-NoIDS snapshot
2. Start VM
3. Install and configure firewall
4. Enable firewall rules
5. Verify firewall active
6. Shutdown VM
7. Create snapshot: 'OPNsense-Only'

**Acceptance Criteria**:
- [ ] Firewall installed successfully
- [ ] Firewall rules enabled
- [ ] Firewall active
- [ ] Snapshot created
- [ ] Snapshot can be restored

**Note**: If OPNsense incompatible, use Windows Firewall with advanced security and document substitution.

---

### TASK-022: Run Firewall Tests (All Criteria)
**Priority**: P0 (Blocker)  
**Estimated Time**: 5-6 hours  
**Dependencies**: TASK-021

**Description**: Run all 6 criteria tests on firewall-only configuration (5 iterations each).

**Steps**:
1. Restore OPNsense-Only snapshot
2. Run boot time test (Criterion A) → `Z:\data\opnsense\boot-time-opnsense.csv`
3. Run RAM startup test (Criterion B) → `Z:\data\opnsense\ram-startup-opnsense.csv`
4. Run process count test (Criterion C) → `Z:\data\opnsense\process-count-opnsense.csv`
5. Run app launch test (Criterion D) → `Z:\data\opnsense\app-launch-opnsense.csv`
6. Run SMB copy test (Criterion E) → `Z:\data\opnsense\smb-copy-opnsense.csv`
7. Run FTP download test (Criterion F) → `Z:\data\opnsense\ftp-download-opnsense.csv`

**Acceptance Criteria**:
- [ ] All 6 criteria tested (5 iterations each)
- [ ] All CSV files generated in Z:\data\
- [ ] Variance <10% per criterion
- [ ] Data saved to opnsense directory

---

### TASK-023: Calculate Firewall Overhead
**Priority**: P1 (High)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-022

**Description**: Calculate percentage overhead for firewall configuration vs baseline.

**Steps**:
1. Load baseline and OPNsense CSV files from C:\VMShare\data\
2. Calculate average for each criterion
3. Calculate percentage overhead
4. Document results

**Acceptance Criteria**:
- [ ] Overhead calculated for all 6 criteria
- [ ] Results documented
- [ ] Overhead percentages reasonable (5-25%)

---

## Phase 4: Combined Configuration (Day 7) - 8-10 hours

### TASK-024: Install Both Symantec + OPNsense
**Priority**: P0 (Blocker)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-023

**Description**: Install both IDS components on clean baseline and create snapshot.

**Steps**:
1. Restore Baseline-NoIDS snapshot
2. Start VM
3. Install Symantec Endpoint Protection
4. Install OPNsense/firewall
5. Verify both active simultaneously
6. Shutdown VM
7. Create snapshot: 'Symantec-OPNsense-Both'

**Acceptance Criteria**:
- [ ] Both Symantec and firewall installed
- [ ] Both active simultaneously
- [ ] No conflicts detected
- [ ] Snapshot created
- [ ] Snapshot can be restored

---

### TASK-025: Run Combined Tests (All Criteria)
**Priority**: P0 (Blocker)  
**Estimated Time**: 5-6 hours  
**Dependencies**: TASK-024

**Description**: Run all 6 criteria tests on combined configuration (5 iterations each).

**Steps**:
1. Restore Symantec-OPNsense-Both snapshot
2. Run boot time test (Criterion A) → `Z:\data\both\boot-time-both.csv`
3. Run RAM startup test (Criterion B) → `Z:\data\both\ram-startup-both.csv`
4. Run process count test (Criterion C) → `Z:\data\both\process-count-both.csv`
5. Run app launch test (Criterion D) → `Z:\data\both\app-launch-both.csv`
6. Run SMB copy test (Criterion E) → `Z:\data\both\smb-copy-both.csv`
7. Run FTP download test (Criterion F) → `Z:\data\both\ftp-download-both.csv`

**Acceptance Criteria**:
- [ ] All 6 criteria tested (5 iterations each)
- [ ] All CSV files generated in Z:\data\
- [ ] Variance <10% per criterion
- [ ] Data saved to both directory

---

### TASK-026: Calculate Combined Overhead
**Priority**: P1 (High)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-025

**Description**: Calculate percentage overhead for combined configuration vs baseline.

**Steps**:
1. Load baseline and combined CSV files from C:\VMShare\data\
2. Calculate average for each criterion
3. Calculate percentage overhead
4. Document results
5. Compare with individual overheads

**Acceptance Criteria**:
- [ ] Overhead calculated for all 6 criteria
- [ ] Results documented
- [ ] Overhead percentages reasonable (15-50%)
- [ ] Comparison with individual configs noted

---

## Phase 5: Data Analysis (Days 8-9) - 6-8 hours

### TASK-027: Consolidate All Measurement Data
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-026

**Description**: Import and consolidate all CSV files from C:\VMShare\data\ into master spreadsheet or analysis tool.

**Steps**:
1. Create analysis spreadsheet/notebook
2. Import all 24 CSV files (4 configs × 6 criteria)
3. Organize by criterion and configuration
4. Calculate summary statistics
5. Document any anomalies

**Acceptance Criteria**:
- [ ] All 24 CSV files imported from C:\VMShare\data\
- [ ] Data organized by criterion (A-F)
- [ ] Summary statistics calculated
- [ ] Anomalies documented

---

### TASK-028: Generate Comparative Graphs
**Priority**: P0 (Blocker)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-027

**Description**: Create 6 comparative graphs (one per criterion A-F) showing all 4 configurations.

**Graphs to Create**:
1. Criterion A: Boot time comparison (seconds)
2. Criterion B: RAM usage comparison (MB)
3. Criterion C: Process count comparison
4. Criterion D: Application launch time comparison (seconds for 75 apps)
5. Criterion E: SMB copy speed comparison (MB/s)
6. Criterion F: FTP download speed comparison (Mbps)

**Format**: Bar charts or line graphs suitable for LaTeX inclusion

**Acceptance Criteria**:
- [ ] 6 graphs generated (one per criterion A-F)
- [ ] All 4 configurations shown per graph
- [ ] Graphs properly labeled (axis, legend)
- [ ] Saved as high-quality images (PNG/PDF)
- [ ] Saved to `lncs-enhanced-main/figures/`

---

### TASK-029: Create Results Tables
**Priority**: P0 (Blocker)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-027

**Description**: Create LaTeX-formatted tables with measurement data and overhead percentages.

**Tables to Create**:
1. Summary table (all criteria, all configs)
2. Overhead percentage table
3. Statistical significance table (variance, std dev)

**Acceptance Criteria**:
- [ ] 3 tables created in LaTeX format
- [ ] All data included with units
- [ ] Tables properly formatted
- [ ] Ready for paper inclusion

---

### TASK-030: Write Analysis Summary
**Priority**: P1 (High)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-029

**Description**: Document key findings and patterns in the data.

**Content**:
- Which criteria show highest overhead?
- Which configuration has most impact?
- Are there unexpected results?
- Statistical significance of findings

**Acceptance Criteria**:
- [ ] Summary document created
- [ ] Key findings documented
- [ ] Patterns identified
- [ ] Ready for Discussion section

---

## Phase 6: LaTeX Paper Writing (Days 10-13) - 16-20 hours

### TASK-031: Write Paper Abstract
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-030

**Description**: Write concise abstract (150-250 words) summarizing research.

**Content**:
- Problem statement
- Methodology (4 configs, 6 criteria)
- Key findings (overhead percentages)
- Conclusion

**Acceptance Criteria**:
- [ ] Abstract written (150-250 words)
- [ ] Contains all required elements
- [ ] Clear and concise
- [ ] No plagiarism

---

### TASK-032: Write Introduction Section
**Priority**: P0 (Blocker)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-031

**Description**: Write Introduction section establishing context and objectives.

**Content**:
- Background on IDS importance
- Problem: performance overhead
- Research objectives
- Paper structure

**Acceptance Criteria**:
- [ ] Introduction written (1-1.5 pages)
- [ ] Context established
- [ ] Objectives clear
- [ ] No plagiarism

---

### TASK-033: Write Related Work Section
**Priority**: P0 (Blocker)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-032

**Description**: Write Related Work section reviewing existing research on IDS performance.

**Content**:
- Previous studies on AV performance impact
- Firewall performance studies
- Benchmarking methodologies
- How this work differs/contributes

**Acceptance Criteria**:
- [ ] Related Work written (1 page)
- [ ] At least 5 references cited
- [ ] Properly contextualized
- [ ] No plagiarism

---

### TASK-034: Write Methodology Section
**Priority**: P0 (Blocker)  
**Estimated Time**: 3 hours  
**Dependencies**: TASK-033

**Description**: Write comprehensive Methodology section describing test setup and procedures.

**Content**:
- 4 configurations detailed (Baseline, Symantec-only, Firewall-only, Both)
- 6 criteria explained:
  * Criterion A: Boot time (BootRacer)
  * Criterion B: RAM at startup
  * Criterion C: Process count
  * Criterion D: App launch (75 apps × 5 iterations = 375 total launches)
  * Criterion E: SMB transfer (1GB to 192.168.50.99/Public/Test)
  * Criterion F: FTP download (100MB from DIGI Storage)
- Tools used (BootRacer, Task Manager/Perfmon, AV-Bench/script.ps1, PowerShell scripts)
- Network setup (QNAP NAS via SMB, DIGI Storage via FTP configured with FileZilla)
- Testing procedure (5 iterations per test)
- Data collection (C:\VMShare on host mapped to Z: on guest)

**Acceptance Criteria**:
- [ ] Methodology written (2-2.5 pages)
- [ ] All details included
- [ ] Reproducible description
- [ ] Figures/tables referenced
- [ ] No plagiarism

---

### TASK-035: Write Results Section
**Priority**: P0 (Blocker)  
**Estimated Time**: 3 hours  
**Dependencies**: TASK-034, TASK-028, TASK-029

**Description**: Write Results section presenting measurement data with tables and graphs.

**Content**:
- Present all 6 criteria results:
  * Criterion A: Boot time
  * Criterion B: RAM usage
  * Criterion C: Process count
  * Criterion D: App launch (375 total launches)
  * Criterion E: SMB transfer
  * Criterion F: FTP download
- Include tables with data
- Include 6 comparative graphs
- Report overhead percentages
- Statistical variance data

**Acceptance Criteria**:
- [ ] Results written (2 pages)
- [ ] All 6 graphs included (A-F)
- [ ] All tables included
- [ ] Data clearly presented
- [ ] No interpretation (save for Discussion)

---

### TASK-036: Write Discussion Section
**Priority**: P0 (Blocker)  
**Estimated Time**: 3 hours  
**Dependencies**: TASK-035

**Description**: Write Discussion section analyzing and interpreting results.

**Content**:
- Interpret overhead patterns
- Explain differences between configs
- Compare with related work
- Discuss unexpected results
- Limitations of study
- Implications for users

**Acceptance Criteria**:
- [ ] Discussion written (1.5-2 pages)
- [ ] Insightful analysis
- [ ] Results explained
- [ ] Limitations acknowledged
- [ ] No plagiarism

---

### TASK-037: Write Conclusion Section
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-036

**Description**: Write Conclusion section summarizing findings and implications.

**Content**:
- Summarize key findings
- Answer research questions
- Practical implications
- Future work suggestions

**Acceptance Criteria**:
- [ ] Conclusion written (0.5-1 page)
- [ ] Findings summarized
- [ ] Implications stated
- [ ] No plagiarism

---

### TASK-038: Populate References Section
**Priority**: P0 (Blocker)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-037

**Description**: Create comprehensive reference list with all cited sources.

**Sources to Include**:
- LNCS template
- Symantec documentation
- OPNsense/Windows Firewall documentation
- AV-Bench script information
- SMB protocol documentation
- FTP protocol documentation
- Related research papers (5+)
- 3 testing methodology references from Tom's Hardware or AnandTech
- Windows 11 documentation
- VirtualBox documentation

**Acceptance Criteria**:
- [ ] All references in BibTeX format
- [ ] Added to paper.bib
- [ ] At least 10 references
- [ ] All citations in text
- [ ] Proper formatting

---

### TASK-039: Format and Compile LaTeX Paper
**Priority**: P0 (Blocker)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-038

**Description**: Format paper according to LNCS template and compile to PDF.

**Steps**:
1. Ensure all sections complete
2. Add author information
3. Insert figures correctly
4. Format tables
5. Compile: `latexmk paper` or `lualatex paper`
6. Fix any compilation errors
7. Check PDF output

**Acceptance Criteria**:
- [ ] Paper compiles without errors
- [ ] PDF generated successfully
- [ ] All figures/tables visible
- [ ] Format matches LNCS template
- [ ] Page count ≥7 pages

---

### TASK-040: Proofread and Edit Paper
**Priority**: P0 (Blocker)  
**Estimated Time**: 3 hours  
**Dependencies**: TASK-039

**Description**: Comprehensive proofreading and editing for clarity, grammar, and style.

**Checks**:
- Grammar and spelling
- Technical accuracy
- Clarity of explanations
- Consistency in terminology
- Figure/table captions
- Reference completeness

**Acceptance Criteria**:
- [ ] No grammar/spelling errors
- [ ] Technical content verified
- [ ] Clear and readable
- [ ] Consistent style

---

### TASK-041: Run Plagiarism Check
**Priority**: P0 (Blocker - Critical)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-040

**Description**: Submit paper to TurnItIn and verify plagiarism score ≤7%.

**Steps**:
1. Export paper to PDF
2. Submit to TurnItIn via e-learning system
3. Review plagiarism report
4. If >7%, identify and rewrite flagged sections
5. Resubmit and verify ≤7%

**Acceptance Criteria**:
- [ ] Paper submitted to TurnItIn
- [ ] Plagiarism score ≤7%
- [ ] No major matches identified
- [ ] Ready for final submission

**CRITICAL**: Do not proceed to submission if plagiarism >7%

---

## Phase 7: Final Review & Submission (Day 14) - 2-4 hours

### TASK-042: Final Paper Review
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-041

**Description**: Final comprehensive review of paper before submission.

**Checklist**:
- [ ] 7+ pages?
- [ ] All sections present?
- [ ] All 6 criteria documented (A-F: boot, RAM, process, app launch, SMB, FTP)?
- [ ] All graphs included (6 total for A-F)?
- [ ] All tables formatted correctly?
- [ ] References complete (including 3 from Tom's Hardware/AnandTech)?
- [ ] Author info correct?
- [ ] LNCS format compliance?
- [ ] Plagiarism ≤7%?
- [ ] Compiles without errors?

**Acceptance Criteria**:
- [ ] All checklist items verified
- [ ] No issues found

---

### TASK-043: Package Submission Files
**Priority**: P0 (Blocker)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-042

**Description**: Package both PDF and LaTeX sources for submission.

**Files to Include**:
- paper.pdf (final compiled PDF)
- paper.tex (main LaTeX source)
- paper.bib (references)
- All figure files (PNG/PDF in figures/)
- llncs.cls (LNCS class file)
- Any other required .sty files

**Acceptance Criteria**:
- [ ] All files collected
- [ ] PDF verified final version
- [ ] LaTeX sources complete
- [ ] Compressed into single archive (if required)

---

### TASK-044: Submit to E-Learning System
**Priority**: P0 (Blocker - Critical)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-043

**Description**: Submit final paper to UVT e-learning system before deadline.

**Steps**:
1. Navigate to course in e-learning system
2. Find submission portal
3. Upload PDF
4. Upload LaTeX sources (ZIP if needed)
5. Confirm submission
6. Save confirmation receipt
7. Verify submission timestamp

**Acceptance Criteria**:
- [ ] PDF submitted
- [ ] LaTeX sources submitted
- [ ] Submission confirmed
- [ ] Timestamp before 23 Jan 2026, 21:00
- [ ] Confirmation saved

**CRITICAL**: Must be submitted before deadline!

---

### TASK-045: Post-Submission Backup
**Priority**: P2 (Nice to have)  
**Estimated Time**: 15 minutes  
**Dependencies**: TASK-044

**Description**: Backup all project files after successful submission.

**Steps**:
1. Create backup of entire project directory
2. Include all data files (24 CSV files from C:\VMShare\data\)
3. Include all scripts
4. Include LaTeX sources and PDF
5. Store in safe location (cloud, external drive)

**Acceptance Criteria**:
- [ ] Complete project backup created
- [ ] Stored in multiple locations
- [ ] Verified backup integrity

---

## Summary Statistics

**Total Tasks**: 43 (removed TASK-007 sysbench, removed old TASK-016 sysbench tests)  
**Estimated Total Time**: 65-80 hours over 14 days  
**Critical Path Tasks**: 35 (marked P0)  
**Blocker Tasks**: 40  

**Phase Breakdown**:
- Phase 0 (Setup): 8 tasks, 3.5-5 hours
- Phase 1 (Baseline): 7 tasks, 5.5-7 hours
- Phase 2 (Symantec): 3 tasks, 6-7 hours
- Phase 3 (OPNsense): 3 tasks, 6-7 hours
- Phase 4 (Combined): 3 tasks, 6-7 hours
- Phase 5 (Analysis): 4 tasks, 5-7 hours
- Phase 6 (Writing): 11 tasks, 16-20 hours
- Phase 7 (Submission): 4 tasks, 2-4 hours

**Deadline**: 23 Jan 2026, 21:00 (7 days from spec complete)

**Test Matrix**: 4 configurations × 6 criteria × 5 iterations = **120 test runs** (including 375 total app launches for Criterion D)

---

## Daily Checklist

Use this to track daily progress:

**Day 1**: ☐ TASK-001 through TASK-010 (Setup complete)  
**Day 2**: ☐ TASK-011 through TASK-017 (Baseline complete)  
**Day 3**: ☐ TASK-018 through TASK-020 (Symantec complete)  
**Day 4**: ☐ Continue Symantec testing if needed  
**Day 5**: ☐ TASK-021 through TASK-023 (OPNsense complete)  
**Day 6**: ☐ Continue OPNsense testing if needed  
**Day 7**: ☐ TASK-024 through TASK-026 (Combined complete)  
**Day 8**: ☐ TASK-027 through TASK-030 (Analysis complete)  
**Day 9**: ☐ Continue analysis if needed  
**Day 10**: ☐ TASK-031 through TASK-034 (Intro/Method written)  
**Day 11**: ☐ TASK-035 through TASK-037 (Results/Discussion/Conclusion written)  
**Day 12**: ☐ TASK-038 through TASK-040 (References/Format/Proofread)  
**Day 13**: ☐ TASK-041 (Plagiarism check and fixes)  
**Day 14**: ☐ TASK-042 through TASK-044 (Final review and SUBMIT!)

---

## Next Steps

**Current Phase**: Phase 0 (Environment Setup) - Nearly complete  
**Next Action**: Begin Phase 1 (Baseline Measurements)  
**Status**: ✅ VM configured, shared folder ready, network configured

**Immediate Tasks**:
1. Verify data folder structure exists in C:\VMShare
2. Run baseline measurements (TASK-011 through TASK-016)
3. Verify data quality (TASK-017)

**Good luck! 🚀**

