# Tasks: IDS Impact Analysis Research

**Feature**: `001-av-benchmark` | **Date**: 2026-01-16  
**Status**: Ready to start | **Deadline**: 23 Jan 2026, 21:00

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

### TASK-007: Install sysbench via WSL
**Priority**: P0 (Blocker)  
**Estimated Time**: 45 minutes  
**Dependencies**: None

**Description**: Install Windows Subsystem for Linux and sysbench for criterion (f) testing.

**Steps**:
1. Open PowerShell as Administrator
2. Run: `wsl --install`
3. Reboot if prompted
4. Complete Ubuntu setup
5. Run: `sudo apt-get update && sudo apt-get install sysbench`
6. Verify: `sysbench --version`

**Acceptance Criteria**:
- [ ] WSL installed and functional
- [ ] sysbench installed in WSL
- [ ] Version displayed correctly

**Verification**:
```powershell
wsl sysbench --version
```

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

**Description**: Create directory structure for storing measurement CSV files.

**Steps**:
1. Navigate to project root
2. Create directories: `data/baseline`, `data/symantec`, `data/opnsense`, `data/both`
3. Create `scripts/` directory
4. Verify structure

**Acceptance Criteria**:
- [ ] All data directories created
- [ ] Scripts directory created
- [ ] Structure matches plan.md

**Command**:
```powershell
mkdir data\baseline, data\symantec, data\opnsense, data\both, scripts
```

---

### TASK-010: Create PowerShell Test Scripts
**Priority**: P1 (High)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-009

**Description**: Create PowerShell scripts for automated testing based on provided templates, and modify existing app launch script.

**Scripts to Create**:
1. `scripts/smb-copy-test.ps1` (from NETWORK_TEST_CONFIG.md)
2. `scripts/ftp-download-test.ps1` (from REMOTE_DOWNLOAD_CONFIG.md)
3. `scripts/process-count-test.ps1`
4. `scripts/ram-startup-test.ps1`
5. `scripts/sysbench-wrapper.ps1`

**Script to Modify**:
6. `AV-Bench/script.ps1` - Change `$iterations = 3` to `$iterations = 5`

**Acceptance Criteria**:
- [ ] All 5 scripts created
- [ ] App launch script modified for 5 iterations
- [ ] Scripts include parameter handling
- [ ] Scripts export to CSV
- [ ] Scripts include iteration loops

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

### TASK-016: Run Baseline sysbench Tests
**Priority**: P0 (Blocker)  
**Estimated Time**: 2 hours  
**Dependencies**: TASK-001, TASK-007, TASK-010

**Description**: Run sysbench CPU, memory, and disk I/O tests (criterion f) on baseline configuration.

**Steps**:
1. Restore Baseline-NoIDS snapshot
2. Start VM
3. Run CPU test: `wsl sysbench cpu --threads=4 --time=60 run` (5 iterations)
4. Run memory test: `wsl sysbench memory --memory-total-size=10G run` (5 iterations)
5. Run disk I/O test: `wsl sysbench fileio --file-test-mode=rndrw run` (5 iterations)
6. Save results: `data\baseline\sysbench-*.csv`

**Acceptance Criteria**:
- [ ] CPU test completed (5 iterations)
- [ ] Memory test completed (5 iterations)
- [ ] Disk I/O test completed (5 iterations)
- [ ] CSV files generated
- [ ] Average metrics documented

---

### TASK-016A: Run Baseline Application Launch Test
**Priority**: P0 (Blocker)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-001, TASK-010

**Description**: Run application launch performance test (criterion g) on baseline configuration using modified AV-Bench script.

**Steps**:
1. Restore Baseline-NoIDS snapshot (if needed)
2. Start VM
3. Navigate to: `cd C:\Users\...\ItC\AV-Bench`
4. Run: `.\script.ps1`
5. Wait for 5 iterations to complete (~5-10 minutes)
6. Copy `measurements.csv` to `data\baseline\app-launch-baseline.csv`

**Acceptance Criteria**:
- [ ] 5 iterations completed
- [ ] CSV file generated
- [ ] Variance <10%
- [ ] Average time documented (expected: 8-15 seconds for 75 apps)

---

### TASK-017: Verify Baseline Data Quality
**Priority**: P0 (Blocker)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-011 through TASK-016A

**Description**: Review all baseline measurements for completeness and consistency.

**Steps**:
1. Check all 7 CSV files exist
2. Verify 5 iterations in each file
3. Calculate variance for each criterion
4. Document any issues
5. Re-run tests if variance >10%

**Acceptance Criteria**:
- [ ] All 7 CSV files present
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
**Estimated Time**: 6-8 hours  
**Dependencies**: TASK-018

**Description**: Run all 7 criteria tests on Symantec-Only configuration (5 iterations each).

**Steps**:
1. Restore Symantec-Only snapshot
2. Run SMB copy test → `data\symantec\smb-copy-symantec.csv`
3. Run FTP download test → `data\symantec\ftp-download-symantec.csv`
4. Run process count test → `data\symantec\process-count-symantec.csv`
5. Run RAM startup test → `data\symantec\ram-startup-symantec.csv`
6. Run boot time test → `data\symantec\boot-time-symantec.csv`
7. Run sysbench tests → `data\symantec\sysbench-*.csv`
8. Run app launch test → `data\symantec\app-launch-symantec.csv`

**Acceptance Criteria**:
- [ ] All 7 criteria tested (5 iterations each)
- [ ] All CSV files generated
- [ ] Variance <10% per criterion
- [ ] Data saved to symantec directory

---

### TASK-020: Calculate Symantec Overhead
**Priority**: P1 (High)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-019

**Description**: Calculate percentage overhead for Symantec configuration vs baseline.

**Steps**:
1. Load baseline and Symantec CSV files
2. Calculate average for each criterion
3. Calculate percentage overhead: `((Baseline - Symantec) / Baseline) * 100`
4. Document results

**Acceptance Criteria**:
- [ ] Overhead calculated for all 7 criteria
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
**Estimated Time**: 6-8 hours  
**Dependencies**: TASK-021

**Description**: Run all 7 criteria tests on firewall-only configuration (5 iterations each).

**Steps**:
1. Restore OPNsense-Only snapshot
2. Run SMB copy test → `data\opnsense\smb-copy-opnsense.csv`
3. Run FTP download test → `data\opnsense\ftp-download-opnsense.csv`
4. Run process count test → `data\opnsense\process-count-opnsense.csv`
5. Run RAM startup test → `data\opnsense\ram-startup-opnsense.csv`
6. Run boot time test → `data\opnsense\boot-time-opnsense.csv`
7. Run sysbench tests → `data\opnsense\sysbench-*.csv`
8. Run app launch test → `data\opnsense\app-launch-opnsense.csv`

**Acceptance Criteria**:
- [ ] All 7 criteria tested (5 iterations each)
- [ ] All CSV files generated
- [ ] Variance <10% per criterion
- [ ] Data saved to opnsense directory

---

### TASK-023: Calculate Firewall Overhead
**Priority**: P1 (High)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-022

**Description**: Calculate percentage overhead for firewall configuration vs baseline.

**Steps**:
1. Load baseline and OPNsense CSV files
2. Calculate average for each criterion
3. Calculate percentage overhead
4. Document results

**Acceptance Criteria**:
- [ ] Overhead calculated for all 7 criteria
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
**Estimated Time**: 6-8 hours  
**Dependencies**: TASK-024

**Description**: Run all 7 criteria tests on combined configuration (5 iterations each).

**Steps**:
1. Restore Symantec-OPNsense-Both snapshot
2. Run SMB copy test → `data\both\smb-copy-both.csv`
3. Run FTP download test → `data\both\ftp-download-both.csv`
4. Run process count test → `data\both\process-count-both.csv`
5. Run RAM startup test → `data\both\ram-startup-both.csv`
6. Run boot time test → `data\both\boot-time-both.csv`
7. Run sysbench tests → `data\both\sysbench-*.csv`
8. Run app launch test → `data\both\app-launch-both.csv`

**Acceptance Criteria**:
- [ ] All 7 criteria tested (5 iterations each)
- [ ] All CSV files generated
- [ ] Variance <10% per criterion
- [ ] Data saved to both directory

---

### TASK-026: Calculate Combined Overhead
**Priority**: P1 (High)  
**Estimated Time**: 30 minutes  
**Dependencies**: TASK-025

**Description**: Calculate percentage overhead for combined configuration vs baseline.

**Steps**:
1. Load baseline and combined CSV files
2. Calculate average for each criterion
3. Calculate percentage overhead
4. Document results
5. Compare with individual overheads

**Acceptance Criteria**:
- [ ] Overhead calculated for all 7 criteria
- [ ] Results documented
- [ ] Overhead percentages reasonable (15-50%)
- [ ] Comparison with individual configs noted

---

## Phase 5: Data Analysis (Days 8-9) - 6-8 hours

### TASK-027: Consolidate All Measurement Data
**Priority**: P0 (Blocker)  
**Estimated Time**: 1 hour  
**Dependencies**: TASK-026

**Description**: Import and consolidate all CSV files into master spreadsheet or analysis tool.

**Steps**:
1. Create analysis spreadsheet/notebook
2. Import all 28 CSV files
3. Organize by criterion and configuration
4. Calculate summary statistics
5. Document any anomalies

**Acceptance Criteria**:
- [ ] All 28 CSV files imported
- [ ] Data organized by criterion
- [ ] Summary statistics calculated
- [ ] Anomalies documented

---

### TASK-028: Generate Comparative Graphs
**Priority**: P0 (Blocker)  
**Estimated Time**: 3 hours  
**Dependencies**: TASK-027

**Description**: Create 6 comparative graphs (one per criterion) showing all 4 configurations.

**Graphs to Create**:
1. SMB copy speed comparison (MB/s)
2. FTP download speed comparison (Mbps)
3. Process count comparison
4. RAM usage comparison (MB)
5. Boot time comparison (seconds)
6. sysbench performance comparison (events/s, MB/s, IOPS)
7. Application launch time comparison (seconds for 75 apps)

**Format**: Bar charts or line graphs suitable for LaTeX inclusion

**Acceptance Criteria**:
- [ ] 7 graphs generated
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
- VM specifications (WIN11, 4 cores, 8GB)
- 4 configurations detailed
- 7 criteria explained (a-g)
- Tools used (BootRacer, sysbench, AV-Bench script, etc.)
- Network setup (QNAP, DIGI Storage)
- Testing procedure (5 iterations)
- Data collection methods

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
- Present all 7 criteria results
- Include tables with data
- Include comparative graphs
- Report overhead percentages
- Statistical variance data

**Acceptance Criteria**:
- [ ] Results written (2 pages)
- [ ] All 7 graphs included
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
- OPNsense documentation
- sysbench GitHub
- SMB protocol documentation
- Related research papers (5+)
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
- [ ] all 7 criteria documented?
- [ ] All graphs included?
- [ ] All tables formatted correctly?
- [ ] References complete?
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
2. Include all data files (28 CSV files)
3. Include all scripts
4. Include LaTeX sources and PDF
5. Store in safe location (cloud, external drive)

**Acceptance Criteria**:
- [ ] Complete project backup created
- [ ] Stored in multiple locations
- [ ] Verified backup integrity

---

## Summary Statistics

**Total Tasks**: 46 (added TASK-016A for app launch test)  
**Estimated Total Time**: 72-92 hours over 14 days  
**Critical Path Tasks**: 37 (marked P0)  
**Blocker Tasks**: 43  

**Phase Breakdown**:
- Phase 0 (Setup): 10 tasks, 4-6 hours
- Phase 1 (Baseline): 8 tasks (added TASK-016A), 6.5-8.5 hours
- Phase 2 (Symantec): 3 tasks, 8-10 hours
- Phase 3 (OPNsense): 3 tasks, 8-10 hours
- Phase 4 (Combined): 3 tasks, 8-10 hours
- Phase 5 (Analysis): 4 tasks, 6-8 hours
- Phase 6 (Writing): 11 tasks, 16-20 hours
- Phase 7 (Submission): 4 tasks, 2-4 hours

**Deadline**: 23 Jan 2026, 21:00 (7 days from spec complete)

**Test Matrix**: 4 configurations × 7 criteria × 5 iterations = **140 test runs**

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

**Status**: Ready to begin Phase 0  
**Next Task**: TASK-001 (Configure VM Baseline Snapshot)  
**Good luck! 🚀**

