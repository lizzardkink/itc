# Feature Specification: Intrusion Detection Systems (IDS) Impact Analysis

**Feature Branch**: `001-av-benchmark`  
**Created**: 2026-01-16  
**Updated**: 2026-01-16 15:49 UTC  
**Status**: Draft  
**Input**: User description: "Antivirus performance benchmarking system"  
**Academic Project**: Analysis of the impact of intrusion detection systems on computational resources  
**Deadline**: 23 Jan 2026, 21:00  
**Deliverable**: LaTeX paper (7+ pages) + PDF, using LNCS template

## Test Environment Configuration

**Selected Products**:
- **Antivirus**: Symantec
- **Firewall**: OPNsense

**Hardware/VM Setup**:
- **Platform**: VirtualBox
- **VM Name**: WIN11
- **OS**: Windows 11 (64-bit) [Version: TBD - verify via `winver` or `systeminfo`]
- **CPUs**: 4 virtual processors
- **RAM**: 8 GB (8192 MB)
- **VRAM**: 128 MB
- **Initial State**: Clean snapshot with no antivirus/firewall installed
- **Boot Time Tool**: BootRacer (pre-installed)

**Network Configuration**:
- **Local Network**: 1 Gbit LAN via SMB protocol
- **NAS**: QNAP network storage (mapped via SMB)

---

## Documentation Structure

This specification is part of a comprehensive documentation package:

- **spec.md** (this file) - User stories, acceptance criteria, and test environment
- **plan.md** - Research methodology, timeline, and deliverables
- **tasks.md** - Task breakdown and progress tracking
- **boot-time-methodology.md** - Detailed boot time measurement protocol
- **test-scripts-reference.md** - Complete test automation documentation ⭐
- **guest-setup.md** - VM configuration and setup procedures
- **bibliography-guide.md** - Citation formatting guidelines

## Project Structure

```
ItC/
├── specs/001-av-benchmark/
│   ├── spec.md                        # This file
│   ├── test-scripts-reference.md      # Script documentation ⭐
│   ├── boot-time-methodology.md       # Boot time details
│   └── [other docs]
├── scripts/                            # Main test scripts (run from host)
│   ├── Automated-Boot-Cycle-With-BootRacer.ps1
│   ├── Test-AppLaunch-Remote.ps1
│   ├── FTP-Download-Test.ps1
│   ├── SMB-Copy-Test.ps1
│   └── [utilities]
├── C:\VMShare/                         # Shared folder (Z:\ on VM)
│   ├── Get-LatestBootTime.ps1         # VM helper scripts
│   ├── VM-Helper-*.ps1                # Test executors
│   └── data/                           # CSV results by config
└── analysis/                           # Data analysis outputs
```

**Note**: See `test-scripts-reference.md` for complete script documentation including architecture, usage examples, and troubleshooting.

---
- **Remote Server**: DIGI Storage (FTP connection via FileZilla)

**Shared Folder Mapping & Data Collection**:
- **Host**: C:\VMShare (all test data stored here for access from guest)
- **Guest**: Z: drive (mapped via VirtualBox shared folders)
- **Measurement Storage**: All test results saved to C:\VMShare\data\{config}\{criterion}\ folders
- **Analysis**: Results analyzed from host computer using data in C:\VMShare

**Test Iterations**: 5 iterations per test

## Test Criteria (Reordered)

**Criterion A**: OS boot time measurement (using BootRacer)  
**Criterion B**: RAM consumption at startup  
**Criterion C**: Process count at startup  
**Criterion D**: Application launch performance (AV-Bench/script.ps1 - 30 apps × 5 iterations = 150 total launches)  
**Criterion E**: Local network file transfer speed via SMB (1GB folder copy)  
**Criterion F**: Remote file download speed via FTP (100MB file from DIGI Storage)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Four-Variant System Configuration and Baseline (Priority: P1)

As a researcher, I need to establish and measure 4 distinct system configurations (no IDS, antivirus only, firewall only, antivirus+firewall), so I can perform comparative analysis of IDS impact on computational resources.

**Why this priority**: This is the foundation of the academic project - without all 4 variants properly configured and measured, the comparative study cannot be completed.

**Independent Test**: Can be fully tested by creating 4 separate VM snapshots representing each configuration, verifying each can boot successfully, and confirming the correct software is installed and active in each variant.

**Acceptance Scenarios**:

1. **Given** a clean Windows 11 VM, **When** I create the baseline snapshot with no IDS, **Then** no antivirus or firewall software is running
2. **Given** the baseline snapshot, **When** I install only Symantec antivirus, **Then** a new snapshot "AV-only" is created with AV confirmed active
3. **Given** the baseline snapshot, **When** I install only OPNsense firewall, **Then** a new snapshot "Firewall-only" is created with firewall confirmed active
4. **Given** the baseline snapshot, **When** I install both Symantec and OPNsense, **Then** a new snapshot "AV+Firewall" is created with both confirmed active
5. **Given** all 4 snapshots exist, **When** I restore each snapshot, **Then** the system boots successfully with the correct IDS configuration

---

### User Story 2 - Criterion A: OS Boot Time Measurement (Priority: P1)

As a researcher, I need to measure OS boot time across all 4 configurations using BootRacer, so I can quantify IDS impact on system startup performance.

**Why this priority**: Criterion A (original criterion e) is mandatory for the case study.

**Independent Test**: Can be fully tested by using BootRacer to measure boot time for each configuration, ensuring data is collected consistently.

**Boot Time Components** (as measured by BootRacer):
- **Time to Logon**: Seconds from boot start until Windows logon screen appears
- **Logon Timeout**: Seconds spent at logon screen (if applicable)
- **Logon to Desktop**: Seconds from logon until desktop is fully ready
- **TOTAL BOOT TIME**: Sum of all three components (target: 60-90s baseline)

**Data Source**: `C:\Users\Public\Documents\Bootracer.his` on VM (binary history file)

**Acceptance Scenarios**:

1. **Given** each configuration, **When** I measure boot time using BootRacer, **Then** all three components (Time to Logon, Logon Timeout, Logon to Desktop) are recorded and TOTAL boot time is calculated
2. **Given** all boot time measurements are complete (5 iterations per configuration), **When** I compare results, **Then** percentage impact for each IDS variant is calculated based on TOTAL boot time
3. **Given** measurements are collected, **When** saved to Z:\data\{config}\boot-time-{config}.csv, **Then** CSV files contain: Iteration, Timestamp, TimeToLogon, LogonTimeout, LogonToDesktop, TotalBootTime, Configuration
4. **Given** BootRacer .his file is updated after each boot, **When** script reads `C:\Users\Public\Documents\Bootracer.his`, **Then** the most recent boot entry is parsed correctly and all components are extracted

**Methodology Reference**: See `specs/001-av-benchmark/boot-time-methodology.md` for complete measurement protocol

**Script Reference**: See `specs/001-av-benchmark/test-scripts-reference.md` for detailed script documentation

---

### User Story 3 - Criterion B: RAM Consumption at Startup (Priority: P1)

As a researcher, I need to measure RAM consumption at startup across all 4 configurations, so I can quantify IDS impact on memory resources.

**Why this priority**: Criterion B (original criterion d) is mandatory for the case study.

**Independent Test**: Can be fully tested by measuring RAM usage at startup using Performance Monitor for each configuration.

**Acceptance Scenarios**:

1. **Given** each configuration at startup, **When** I measure RAM consumption using Performance Monitor, **Then** memory usage in MB is recorded immediately after boot completes
2. **Given** all RAM measurements are complete (5 iterations per configuration), **When** I compare results, **Then** percentage impact for each IDS variant is calculated
3. **Given** measurements are collected, **When** saved to Z:\data\ram-usage\, **Then** CSV files contain config name, iteration, and RAM data

---

### User Story 4 - Criterion C: Process Count at Startup (Priority: P1)

As a researcher, I need to count running processes at startup across all 4 configurations, so I can quantify IDS impact on system process overhead.

**Why this priority**: Criterion C (original criterion c) is mandatory for the case study.

**Independent Test**: Can be fully tested by counting Windows processes using PowerShell for each configuration.

**Acceptance Scenarios**:

1. **Given** each of 4 configurations, **When** I count running processes using Task Manager or PowerShell, **Then** process count is recorded for comparison
2. **Given** all process count measurements are complete (5 iterations per configuration), **When** I compare results, **Then** percentage impact for each IDS variant is calculated
3. **Given** measurements are collected, **When** saved to Z:\data\process-count\, **Then** CSV files contain config name, iteration, and count data

---

### User Story 5 - Criterion D: Application Launch Performance (Priority: P2)

As a researcher, I need to measure real-world application launch performance using the existing AV-Bench script to demonstrate IDS impact on process creation and system responsiveness and earn bonus points.

**Why this priority**: Provides additional bonus points and real-world performance data more meaningful than static measurements. Uses actual Windows applications to test IDS overhead on process creation.

**Independent Test**: Can be fully tested by running AV-Bench/script.ps1 which launches 30 application instances (10 Calculator, 10 Paint, 10 Notepad) in randomized order per iteration, runs 5 iterations, and measures total time with automated cleanup.

**Acceptance Scenarios**:

1. **Given** the application launch script exists (AV-Bench/script.ps1), **When** it runs 5 iterations, **Then** it matches the consistency standard of other tests
2. **Given** the script runs on baseline configuration, **When** 30 application instances launch per iteration (5 iterations × 30 = 150 total), **Then** total time is recorded in measurements.csv with <10% variance
3. **Given** baseline measurements are complete, **When** I run the same test on all 4 configurations, **Then** I can calculate percentage overhead for process creation
4. **Given** all configuration data is collected, **When** I analyze results, **Then** I can identify which IDS component has greatest impact on application startup and system responsiveness
5. **Given** measurements are collected, **When** saved to Z:\data\app-launch\, **Then** CSV files contain config name, iteration, and timing data

---

### User Story 6 - Criterion E: Local Network File Transfer Performance (Priority: P1)

As a researcher, I need to measure recursive folder copying speed (1GB+ via local network) across all 4 configurations, so I can quantify IDS impact on network operations.

**Why this priority**: Criterion E (original criterion a) is mandatory for the case study.

**Independent Test**: Can be fully tested by setting up a network file share and performing SMB transfers of 1GB folder, collecting transfer time measurements for each configuration.

**Acceptance Scenarios**:

1. **Given** a 1GB test folder on network share (192.168.50.99/Public/Test), **When** I copy it recursively using SMB from each of 4 configurations, **Then** transfer time is measured and logged in seconds
2. **Given** transfer measurements are complete (5 iterations per configuration), **When** I analyze the data, **Then** I can calculate percentage overhead for each IDS variant compared to baseline
3. **Given** measurements are collected, **When** saved to Z:\data\smb-transfer\, **Then** CSV files contain config name, iteration, file size, and transfer time

---

### User Story 7 - Criterion F: Remote File Download Performance (Priority: P1)

As a researcher, I need to measure remote file download speed (100MB+ from DIGI Storage) across all 4 configurations, so I can quantify IDS impact on remote network operations.

**Why this priority**: Criterion F (original criterion b) is mandatory for the case study.

**Independent Test**: Can be fully tested by downloading a 100MB file via FTP from DIGI Storage and collecting transfer time measurements for each configuration.

**Acceptance Scenarios**:

1. **Given** DIGI Storage FTP server with 100MB test file (configured via FileZilla), **When** I download it via FTP from each of 4 configurations, **Then** download time and speed (MB/s) are measured and logged
2. **Given** transfer measurements are complete (5 iterations per configuration), **When** I analyze the data, **Then** I can calculate percentage overhead for each IDS variant compared to baseline
3. **Given** the network protocol used (FTP), **When** included in documentation, **Then** the protocol is clearly specified in the results
4. **Given** measurements are collected, **When** saved to Z:\data\ftp-download\, **Then** CSV files contain config name, iteration, file size, and download speed

---

### User Story 8 - LaTeX Case Study and Comparative Visualization (Priority: P1)

As a researcher, I need to generate a 7+ page LaTeX case study using the LNCS template with comparative graphs and bibliography references from Tom's Hardware/AnandTech, so I can deliver the academic project in the required format.

**Why this priority**: The LaTeX document and PDF are the primary deliverables - without this, the project cannot be submitted.

**Independent Test**: Can be fully tested by generating a LaTeX document with all sections (introduction, methodology, results, analysis, conclusion), compiling to PDF, and verifying it meets formatting requirements.

**Acceptance Scenarios**:

1. **Given** all measurement data is collected, **When** I generate comparative graphs, **Then** charts clearly show differences between all 4 configurations for each metric
2. **Given** the LNCS LaTeX template, **When** I format the case study, **Then** the document structure follows scientific paper guidelines (abstract, introduction, related work, methodology, results, discussion, conclusion, references)
3. **Given** screenshots are needed, **When** included in the document, **Then** they occupy no more than 25% of any page
4. **Given** the LaTeX sources are complete, **When** compiled, **Then** a PDF of at least 7 pages is generated
5. **Given** the completed document, **When** checked for plagiarism, **Then** TurnItIn similarity score is below 7%
6. **Given** the final deliverable, **When** submitted, **Then** both PDF and complete LaTeX sources are included
7. **Given** bibliography is required, **When** I add references, **Then** 3 testing methodology webpages from Tom's Hardware or AnandTech are included

---

### User Story 9 - Automated Data Collection and Analysis Pipeline (Priority: P3)

As a researcher, I need automated scripts to execute all benchmarks across all 4 configurations and generate CSV data suitable for analysis, so I can efficiently collect consistent measurements.

**Why this priority**: Automation reduces manual errors and ensures repeatability, but manual execution is acceptable if needed.

**Independent Test**: Can be fully tested by running the automation pipeline on all 4 VM snapshots and verifying that CSV files with all required metrics are generated.

**Acceptance Scenarios**:

1. **Given** a VM snapshot for any configuration, **When** I run the benchmark automation script, **Then** all required metrics are measured and logged to CSV
2. **Given** CSV data files from all 4 configurations, **When** I import them into analysis tools, **Then** the data format is consistent and suitable for generating comparative graphs
3. **Given** the automation completes, **When** I review the results, **Then** any measurement failures or anomalies are clearly logged
4. **Given** measurements are collected in VM guest, **When** tests complete, **Then** results are saved to Z:\data\ (mapped to host C:\VMShare)

---

### Edge Cases

- What happens when the VM runs out of disk space during benchmark data collection?
- How does the system handle AV or firewall update interruptions during benchmark execution?
- What happens if one of the benchmark tools (BootRacer, FTP client) is not installed?
- How does the system handle application launch failures during testing?
- What happens if the AV or firewall is in the middle of a scheduled scan during testing?
- How does the benchmark handle VMs with different amounts of RAM or CPU cores?
- What happens if network connectivity is lost during network transfer benchmarks?
- How do we handle firewall prompts that require user interaction during automated testing?
- What happens if the selected antivirus or firewall is not compatible with Windows 11?
- How do we ensure consistent network conditions for file transfer measurements across test runs?

## Requirements *(mandatory)*

### Project Scope & Deliverables

**Academic Context**: This is a practical research project for an academic course, requiring a formal case study following scientific paper structure.

**Project Variants**: Must test 4 distinct configurations:
1. **Baseline (No IDS)**: Clean Windows system with no antivirus or firewall
2. **Antivirus Only**: Selected AV product installed and active
3. **Firewall Only**: Selected firewall product installed and active  
4. **Antivirus + Firewall**: Both products installed and active simultaneously

**Deliverable Format**:
- **Documentation Workflow**: All paper content must first be aggregated into `paper.md` for review before LaTeX conversion
- LaTeX source files using LNCS template (https://github.com/latextemplates/LNCS/archive/main.zip)
- Compiled PDF document (minimum 7 pages)
- Must include comparative graphs
- Screenshots permitted (maximum 25% per page)
- Must pass TurnItIn plagiarism check (≤7% similarity)
- Due: 23 Jan 2026, 21:00
- Bibliography must include 3 relevant testing methodology references from Tom's Hardware or AnandTech
- **IMPORTANT**: LaTeX and PDF conversion only happens after paper.md approval

### Functional Requirements

#### Mandatory Measurements (Reordered Criteria)

- **FR-001**: System MUST measure operating system startup times using BootRacer for each configuration [CRITERION A - Boot Time]
- **FR-002**: System MUST measure RAM memory consumption at system startup for each configuration [CRITERION B - RAM Usage]
- **FR-003**: System MUST count the number of running processes in Windows for each configuration using Task Manager or equivalent tool [CRITERION C - Process Count]
- **FR-004**: System MUST measure application launch performance using AV-Bench/script.ps1 across all 4 configurations [CRITERION D - App Launch]
  - **FR-004a**: Application launch test MUST launch 30 application instances per iteration (10 Calculator, 10 Paint, 10 Notepad)
  - **FR-004b**: Application launch test MUST run 5 iterations per configuration (total: 5 iterations × 30 apps = 150 total application launches)
  - **FR-004c**: Application launch test MUST randomize launch order within each iteration
  - **FR-004d**: Application launch test MUST automatically clean up (close all launched apps) after each iteration
- **FR-005**: System MUST measure recursive folder copy speed (≥1GB) via SMB protocol from QNAP NAS to VM Desktop\SMB folder across all 4 configurations [CRITERION E - Network Copy]
  - **FR-005a**: System MUST specify and document that SMB (Server Message Block) protocol is used for folder copying over local network
  - **FR-005b**: System MUST measure folder transfer from QNAP NAS (192.168.50.99) test folder to C:\Users\admin\Desktop\SMB\ over 1Gbit LAN connection
  - **FR-005c**: System MUST use SMB network path for testing (copy from NAS to local VM Desktop\SMB folder)
- **FR-007**: System MUST perform all measurements consistently across all 4 configurations using identical methodology
- **FR-008**: System MUST perform 5 iterations for each test across all configurations for statistical validity

#### VM Configuration & Snapshot Management

- **FR-009**: System MUST use VirtualBox VM named "Win11" for all testing
- **FR-010**: System MUST maintain clean baseline snapshot with Windows 11 updated and no antivirus or firewall software installed
- **FR-011**: System MUST create four distinct snapshots: (1) Baseline-NoIDS, (2) Symantec-Only, (3) OPNsense-Only, (4) Symantec-OPNsense-Both
- **FR-012**: System MUST verify that selected antivirus (Symantec) is properly installed and active in AV-only and AV+Firewall snapshots
- **FR-013**: System MUST verify that selected firewall (OPNsense) is properly installed and active in Firewall-only and AV+Firewall snapshots
- **FR-014**: System MUST document exact VM specifications (RAM, CPU cores, disk size) from VirtualBox configuration for methodology section
- **FR-015**: System MUST be able to restore snapshots reliably for repeatable testing across all measurements
- **FR-016**: System MUST configure VirtualBox shared folder between host computer and Win11 VM for automatic data collection
- **FR-016a**: Shared folder C:\VMShare on host MUST be mapped to Z: drive inside Win11 VM guest via VirtualBox shared folders
- **FR-016b**: All test scripts (BootRacer exports, AV-Bench script.ps1, PowerShell test scripts) MUST save measurement results directly to Z:\data\ folder
- **FR-016c**: Shared folder MUST persist measurement data even after VM snapshots are restored to prevent data loss
- **FR-016d**: System MUST verify shared folder read/write permissions work correctly before beginning test iterations
- **FR-016e**: All measurement data is stored in C:\VMShare on host for accessibility from both host and guest systems

#### Data Collection & Analysis

- **FR-017**: System MUST persist all measurement data in structured format (CSV or equivalent) with configuration labels to shared folder
- **FR-017a**: Measurement files MUST include metadata: configuration name, iteration number, timestamp, criterion measured
- **FR-018**: System MUST execute each benchmark test 5 iterations to ensure statistical consistency and reliability
- **FR-019**: System MUST calculate percentage impact/overhead for each metric by comparing each IDS configuration to baseline
- **FR-020**: System MUST generate comparative graphs showing all 4 configurations for each measured criterion
- **FR-021**: System MUST ensure graphs are suitable for inclusion in LaTeX document

#### LaTeX Document Generation

- **FR-021A**: System MUST first aggregate all paper content into paper.md in Markdown format for user review
- **FR-021B**: LaTeX conversion and PDF compilation MUST only proceed after paper.md receives user approval
- **FR-022**: System MUST generate LaTeX source using the mandatory LNCS template
- **FR-023**: Document MUST follow scientific paper structure: abstract, introduction, related work, methodology, results, discussion, conclusion, references
- **FR-024**: Document MUST include methodology section describing test setup, VM specifications, software versions, and measurement procedures
- **FR-024a**: Methodology MUST document shared folder configuration for automated data collection from VM to host computer
- **FR-025**: Document MUST include results section with tables and comparative graphs for all measured criteria
- **FR-026**: Document MUST include discussion/analysis section interpreting the results and explaining performance differences
- **FR-027**: Document MUST include references to relevant academic papers or technical sources
- **FR-028**: Document MUST be at least 7 pages when compiled to PDF
- **FR-029**: Document MAY include screenshots but they must not exceed 25% of any page
- **FR-030**: Document MUST be checked for plagiarism and maintain ≤7% similarity score

#### Network Testing Setup

- **FR-032**: System MUST establish 1 Gigabit LAN connection from WIN11 VM to network share (192.168.50.99:/Public/Test) for folder copy testing
- **FR-033**: System MUST configure VirtualBox network adapter to Bridged mode to access local network and network share
- **FR-034**: System MUST establish FTP connection from WIN11 VM to DIGI Storage server (configured via FileZilla) for remote file download testing
- **FR-035**: System MUST create or identify a 1GB test folder on network share (192.168.50.99:/Public/Test) for network copy benchmarks
- **FR-036**: System MUST create or identify a test file of at least 100MB on DIGI Storage server accessible via FTP for download testing
- **FR-037**: System MUST ensure consistent network conditions across test runs (or document any variations in throughput)
- **FR-038**: System MUST include 3 relevant testing methodology references from Tom's Hardware or AnandTech in bibliography

### Key Entities

- **IDS Configuration**: One of 4 variants (No IDS, AV-only, Firewall-only, AV+Firewall), each represented by a VM snapshot with specific software installed
- **Measurement Record**: Individual data point captured during benchmark execution, containing criterion name (a-f), value, unit, timestamp, iteration number, and configuration label
- **Performance Criterion**: Specific measurable aspect mandated by project requirements (folder copy speed, download speed, process count, RAM usage, boot time, additional criterion)
- **Test Environment**: Complete setup including VM specifications, network topology (local network + remote server), selected AV product, selected firewall product, and measurement tools
- **LaTeX Document**: Academic case study deliverable containing all sections (abstract through conclusion), comparative graphs, and analysis following LNCS template format
- **Comparative Graph**: Visualization showing all 4 configurations for a single performance criterion, suitable for LaTeX inclusion
- **Benchmark Suite**: Collection of all measurement scripts and tools needed to execute criteria a-f across all 4 configurations

## Success Criteria *(mandatory)*

### Measurable Outcomes

#### Configuration & Setup (Critical Path)

- **SC-001**: All 4 VM configuration snapshots are successfully created (No IDS, AV-only, Firewall-only, AV+Firewall)
- **SC-002**: Selected antivirus product is properly installed, activated, and verified in AV-only and AV+Firewall configurations
- **SC-003**: Selected firewall product is properly installed, activated, and verified in Firewall-only and AV+Firewall configurations
- **SC-004**: Baseline (No IDS) configuration is verified to have no antivirus or firewall software running
- **SC-005**: VirtualBox shared folder (C:\VMShare on host) is successfully configured and mapped to Z: drive in Win11 VM
- **SC-006**: Shared folder is accessible from inside VM with read/write permissions verified
- **SC-007**: All test scripts successfully write measurement data to Z: drive visible from host computer
- **SC-008**: Shared folder data persists correctly after VM snapshot restore operations

#### Mandatory Measurements (Criteria a-e - Reordered)

- **SC-009**: OS boot time is successfully measured using BootRacer for all 4 configurations (5 iterations each) [CRITERION A - Boot Time]
- **SC-010**: RAM consumption at startup is successfully measured and recorded for all 4 configurations (5 iterations each) [CRITERION B - RAM Usage]
- **SC-011**: Process count is successfully measured and recorded for all 4 configurations (5 iterations each) [CRITERION C - Process Count]
- **SC-012**: Remote file download speed (≥100MB from DIGI Storage via FTP) is successfully measured across all 4 configurations (5 iterations each) [CRITERION D - Remote Download]
- **SC-013**: Folder copy speed (≥1GB via SMB on local network to 192.168.50.99) is successfully measured across all 4 configurations (5 iterations each) using documented protocol (SMB) [CRITERION E - Network Copy]
- **SC-014**: All mandatory measurements show consistent results with variance <10% across 5 iterations per configuration

#### Additional Criterion (Bonus Points - Criterion f)

- **SC-015**: Application launch script (AV-Bench/script.ps1) runs 5 iterations per configuration [CRITERION F - App Launch]
- **SC-015a**: Script successfully launches 30 application instances per iteration (150 total across 5 iterations) and records timing data to CSV across all 4 configurations
- **SC-015b**: Application launch results show <10% variance within iterations demonstrating measurement consistency
- **SC-015c**: Results reveal meaningful differences in process creation overhead between IDS configurations
- **SC-015d**: Application launch performance data is properly documented in the case study with clear rationale for real-world relevance

#### Data Analysis & Visualization

- **SC-016**: Percentage impact/overhead is accurately calculated for each criterion by comparing each IDS configuration to baseline
- **SC-017**: Comparative graphs are generated showing all 4 configurations for each measured criterion (a-f, 6 total graphs)
- **SC-018**: All graphs are properly formatted and suitable for LaTeX document inclusion
- **SC-019**: All measurement data is available in structured format (CSV) for verification and reproducibility

#### LaTeX Document Deliverable

- **SC-020**: LaTeX source files compile successfully to PDF without errors
- **SC-021**: Compiled PDF document meets minimum 7-page requirement
- **SC-022**: Document uses mandatory LNCS template correctly with proper formatting
- **SC-023**: Document includes all required sections: abstract, introduction, related work, methodology, results, discussion, conclusion, references
- **SC-024**: Methodology section clearly describes test setup, VM specs, software versions, selected AV/firewall products, and measurement procedures
- **SC-025**: Methodology section documents shared folder configuration for automated data collection from VM to host computer
- **SC-026**: Results section includes tables and comparative graphs for all 6 measured criteria (a-f)
- **SC-027**: Discussion section provides insightful analysis explaining performance differences between configurations
- **SC-028**: Screenshots (if included) do not exceed 25% of any page
- **SC-029**: Document passes TurnItIn plagiarism check with ≤7% similarity score
- **SC-030**: Both PDF and complete LaTeX sources are ready for submission

**Network Testing Infrastructure**

- **SC-031**: 1 Gigabit LAN connection between WIN11 VM and network share (192.168.50.99:/Public/Test mapped via SMB) is established and functional for folder copy testing
- **SC-032**: FTP connection to DIGI Storage server (configured via FileZilla) is accessible and functional for remote download testing
- **SC-033**: Test folder of ≥1GB is created/available on network share for network copy benchmarks
- **SC-034**: Test file of ≥100MB is created/available on DIGI Storage for FTP download benchmarks
- **SC-035**: Network conditions remain consistent across test runs, or variations are documented
- **SC-036**: Bibliography includes 3 relevant testing methodology references from Tom's Hardware or AnandTech

#### Project Completion

- **SC-037**: All deliverables (PDF + LaTeX sources) are ready for submission before deadline (23 Jan 2026, 21:00)
- **SC-038**: Selected antivirus (Symantec) and firewall (OPNsense) products are documented in project submission
- **SC-039**: Project meets all academic requirements for maximum grade eligibility (including bonus points from criterion f - application launch testing)

## Product Selection & Technical Constraints

### Available Antivirus Products (Select One)

Students must select ONE antivirus from the list below on a first-come, first-served basis:

1. Ad-Aware, 2. AegisLab, 3. AhnLab-V3, 4. AntiVir, 5. Antiy-AVL, 6. Avast, 7. AVG, 8. Baidu-International, 9. BitDefender, 10. ByteHero, 11. CAT-QuickHeal, 12. ClamAV, 13. CMC, 14. Commtouch, 15. Comodo, 16. DrWeb, 17. Emsisoft, 18. eScan, 19. ESET-NOD32, 20. F-Prot, 21. F-Secure, 22. Fortinet, 23. GData, 24. Ikarus, 25. Jiangmin, 26. K7AntiVirus, 27. K7GW, 28. Kaspersky, 29. Kingsoft, 30. Malwarebytes, 31. McAfee, 32. McAfee-GW-Edition, 33. Microsoft, 34. NANO-Antivirus, 35. Norman, 36. nProtect, 37. Panda, 38. Qihoo-360, 39. Rising, 40. Sophos, 41. SUPERAntiSpyware, 42. Symantec, 43. Tencent, 44. TheHacker, 45. TotalDefense, 46. TrendMicro, 47. TrendMicro-HouseCall, 48. VBA32, 49. VIPRE, 50. ViRobot, 51. Yandex, 52. Zillya

**Selected Antivirus**: Symantec

### Available Firewall Products (Select One)

Students must select ONE firewall from the list below on a first-come, first-served basis:

1. SolarWinds Network Firewall Security Management, 2. System Mechanic Ultimate Defense, 3. Norton, 4. LifeLock, 5. ZoneAlarm, 6. Comodo Firewall, 7. TinyWall, 8. Netdefender, 9. Glasswire, 10. PeerBlock, 11. AVS Firewall, 12. OpenDNS Home, 13. Privatefirewall, 14. Avast Endpoint Firewall, 15. Mcafee Firewall, 16. Azure Firewall, 17. Evorim, 18. Untangle, 19. eScan Advanced Firewall, 20. Sophos XG Firewall, 21. Outpost Firewall, 22. R-Firewall, 23. Ashampoo FireWall, 24. pfSense, 25. Little Snitch, 26. OPNsense

**Selected Firewall**: OPNsense

### Technical Constraints

- **Operating System**: Windows 11 (updated to latest version)
- **Virtualization**: VirtualBox with VM named "Win11"
- **VM Snapshot Strategy**: Clean baseline snapshot exists with OS updated, no antivirus or firewall installed
- **Network Setup**: 1 Gigabit LAN connection to QNAP NAS for folder copy testing; FTP connection to DIGI Storage for remote download
- **Network Protocol (Criterion a)**: SMB (Server Message Block) for 1GB folder copy test over local network
- **Network Protocol (Criterion b)**: FTP (File Transfer Protocol) for 100MB remote download test
- **Test Data**: 1GB folder on QNAP NAS for local copy, 100MB file on DIGI Storage for remote download
- **Technical Constraints**: Must document all tools used (BootRacer for boot times, Task Manager/perfmon for processes/RAM, AV-Bench/script.ps1 for app launch)
- **Application Launch Tool (Criterion D)**: AV-Bench/script.ps1 for application launch performance testing (30 app instances per iteration: 5 iterations × 30 apps = 150 total launches)
- **Data Collection**: All measurement data stored in C:\VMShare on host (mapped to Z: on guest) for accessibility
- **LaTeX Template**: LNCS template mandatory (https://github.com/latextemplates/LNCS/archive/main.zip)
- **Plagiarism Limit**: Maximum 7% similarity on TurnItIn
- **Document Length**: Minimum 7 pages
- **Deadline**: 23 Jan 2026, 21:00

### Open Questions Requiring Clarification

1. ~~Which antivirus product will be selected?~~ **RESOLVED: Symantec**
2. ~~Which firewall product will be selected?~~ **RESOLVED: OPNsense**
3. ~~Which network protocol for folder copying?~~ **RESOLVED: SMB protocol on 1Gbit LAN to 192.168.50.99:/Public/Test**
4. ~~What will be the additional criterion (f)?~~ **RESOLVED: Application launch performance using AV-Bench/script.ps1 (30 instances per iteration, 150 total across 5 iterations)**
5. ~~What are the exact VM specifications?~~ **RESOLVED: VirtualBox VM named "Win11" with clean snapshot (OS updated, no AV/firewall), BootRacer pre-installed**
6. ~~What remote server will be used for download testing?~~ **RESOLVED: DIGI Storage server via FTP (configured via FileZilla)**
7. ~~How many iterations per test?~~ **RESOLVED: 5 iterations per test for all measurements (150 total app launches for Criterion D)**
8. ~~What is the optional bonus criterion (g)?~~ **RESOLVED: Removed - sysbench not supported on Windows, renounced completely**
9. ~~How will we gather measurements from the VM?~~ **RESOLVED: C:\VMShare on host mapped to Z: drive in guest; all data in C:\VMShare for accessibility from both systems**
10. ~~Can installations be done via CLI?~~ **RESOLVED: Yes, where possible using CLI commands (e.g., Windows Firewall via PowerShell)**

### Reference Materials

- **Testing Criteria Reference**: https://pastebin.com/fnxDqJ7V (illustrative purposes only)
- **LNCS LaTeX Template**: https://github.com/latextemplates/LNCS/archive/main.zip (mandatory)
- **Paper Structure Examples**: https://uvt-ro.academia.edu/CiprianPungila (follow same layout as scientific papers)
- **Application Launch Script**: AV-Bench/script.ps1 (for bonus criterion f - real-world app performance with 30 apps per iteration)
- **Testing Methodology References**: Tom's Hardware and AnandTech benchmark methodologies (3 references required in bibliography for relevant testing methods)
- **Project Tracking**: All project information maintained in speckit format (spec.md, plan.md, tasks.md, guest-setup.md)
