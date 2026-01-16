# Feature Specification: Intrusion Detection Systems (IDS) Impact Analysis

**Feature Branch**: `001-av-benchmark`  
**Created**: 2026-01-16  
**Updated**: 2026-01-16  
**Status**: Draft  
**Input**: User description: "Antivirus performance benchmarking system"  
**Academic Project**: Analysis of the impact of intrusion detection systems on computational resources  
**Deadline**: 23 Jan 2026, 21:00  
**Deliverable**: LaTeX paper (7+ pages) + PDF, using LNCS template

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Four-Variant System Configuration and Baseline (Priority: P1)

As a researcher, I need to establish and measure 4 distinct system configurations (no IDS, antivirus only, firewall only, antivirus+firewall), so I can perform comparative analysis of IDS impact on computational resources.

**Why this priority**: This is the foundation of the academic project - without all 4 variants properly configured and measured, the comparative study cannot be completed.

**Independent Test**: Can be fully tested by creating 4 separate VM snapshots representing each configuration, verifying each can boot successfully, and confirming the correct software is installed and active in each variant.

**Acceptance Scenarios**:

1. **Given** a clean Windows 11 VM, **When** I create the baseline snapshot with no IDS, **Then** no antivirus or firewall software is running
2. **Given** the baseline snapshot, **When** I install only the selected antivirus, **Then** a new snapshot "AV-only" is created with AV confirmed active
3. **Given** the baseline snapshot, **When** I install only the selected firewall, **Then** a new snapshot "Firewall-only" is created with firewall confirmed active
4. **Given** the baseline snapshot, **When** I install both antivirus and firewall, **Then** a new snapshot "AV+Firewall" is created with both confirmed active
5. **Given** all 4 snapshots exist, **When** I restore each snapshot, **Then** the system boots successfully with the correct IDS configuration

---

### User Story 2 - Network File Transfer Performance Measurement (Priority: P1)

As a researcher, I need to measure recursive folder copying speed (1GB+ via local network) and remote file download speed (100MB+) across all 4 configurations, so I can quantify IDS impact on network operations.

**Why this priority**: Criteria (a) and (b) from the project requirements are mandatory measurements for the case study.

**Independent Test**: Can be fully tested by setting up a network file share, performing FTP/SFTP transfers of 1GB folder and 100MB file, and collecting transfer time measurements for each configuration.

**Acceptance Scenarios**:

1. **Given** a 1GB test folder on network share, **When** I copy it recursively using FTP/SFTP from each of 4 configurations, **Then** transfer time is measured and logged in seconds
2. **Given** a remote server with 100MB test file, **When** I download it from each of 4 configurations, **Then** download time and speed (MB/s) are measured and logged
3. **Given** transfer measurements are complete, **When** I analyze the data, **Then** I can calculate percentage overhead for each IDS variant compared to baseline
4. **Given** the network protocol used (e.g., FTP, SFTP), **When** included in documentation, **Then** the protocol is clearly specified in the results

---

### User Story 3 - System Resource Consumption Measurement (Priority: P1)

As a researcher, I need to measure process count, RAM consumption at startup, and OS boot time across all 4 configurations, so I can quantify IDS impact on system resources.

**Why this priority**: Criteria (c), (d), and (e) from the project requirements are mandatory measurements for the case study.

**Independent Test**: Can be fully tested by measuring Windows process count, RAM usage at startup, and boot time using BootRacer for each configuration, ensuring data is collected consistently.

**Acceptance Scenarios**:

1. **Given** each of 4 configurations, **When** I count running processes using Task Manager or PowerShell, **Then** process count is recorded for comparison
2. **Given** each configuration at startup, **When** I measure RAM consumption using Performance Monitor, **Then** memory usage in MB is recorded immediately after boot completes
3. **Given** each configuration, **When** I measure boot time using BootRacer or similar tool, **Then** time-to-logon and time-to-desktop are recorded in seconds
4. **Given** all resource measurements are complete, **When** I compare results, **Then** percentage impact for each IDS variant is calculated

---

### User Story 4 - Additional Performance Criteria (Priority: P2)

As a researcher, I need to measure system performance using sysbench (from GitHub) across all 4 configurations to earn bonus points and provide comprehensive CPU/memory/disk I/O benchmarking.

**Why this priority**: Required for bonus points (up to 20) and sysbench provides standardized, reproducible benchmarks for CPU, memory, and disk I/O performance that clearly demonstrate IDS impact.

**Independent Test**: Can be fully tested by installing sysbench from GitHub, running CPU/memory/disk benchmarks across all 4 configurations, and documenting the rationale for why system benchmarking reveals IDS overhead.

**Acceptance Scenarios**:

1. **Given** sysbench is installed from GitHub, **When** I document the rationale, **Then** the explanation clearly describes why system benchmarking (CPU/memory/disk I/O) matters for IDS impact analysis
2. **Given** sysbench is configured, **When** I run CPU benchmarks across all 4 configurations, **Then** comparable data (operations per second, execution time) is collected and logged
3. **Given** sysbench is configured, **When** I run memory benchmarks across all 4 configurations, **Then** comparable data (throughput, latency) is collected and logged
4. **Given** sysbench is configured, **When** I run disk I/O benchmarks across all 4 configurations, **Then** comparable data (IOPS, throughput) is collected and logged
5. **Given** all sysbench measurements are complete, **When** included in the case study, **Then** the methodology, results, and analysis are clearly documented with proper attribution to sysbench project
6. **Given** sysbench results, **When** compared across configurations, **Then** the data reveals meaningful differences showing IDS overhead on system resources

---

### User Story 5 - LaTeX Case Study and Comparative Visualization (Priority: P1)

As a researcher, I need to generate a 7+ page LaTeX case study using the LNCS template with comparative graphs, so I can deliver the academic project in the required format.

**Why this priority**: The LaTeX document and PDF are the primary deliverables - without this, the project cannot be submitted.

**Independent Test**: Can be fully tested by generating a LaTeX document with all sections (introduction, methodology, results, analysis, conclusion), compiling to PDF, and verifying it meets formatting requirements.

**Acceptance Scenarios**:

1. **Given** all measurement data is collected, **When** I generate comparative graphs, **Then** charts clearly show differences between all 4 configurations for each metric
2. **Given** the LNCS LaTeX template, **When** I format the case study, **Then** the document structure follows scientific paper guidelines (abstract, introduction, related work, methodology, results, discussion, conclusion, references)
3. **Given** screenshots are needed, **When** included in the document, **Then** they occupy no more than 25% of any page
4. **Given** the LaTeX sources are complete, **When** compiled, **Then** a PDF of at least 7 pages is generated
5. **Given** the completed document, **When** checked for plagiarism, **Then** TurnItIn similarity score is below 7%
6. **Given** the final deliverable, **When** submitted, **Then** both PDF and complete LaTeX sources are included

---

### User Story 6 - Automated Data Collection and Analysis Pipeline (Priority: P3)

As a researcher, I need automated scripts to execute all benchmarks across all 4 configurations and generate CSV data suitable for analysis, so I can efficiently collect consistent measurements.

**Why this priority**: Automation reduces manual errors and ensures repeatability, but manual execution is acceptable if needed.

**Independent Test**: Can be fully tested by running the automation pipeline on all 4 VM snapshots and verifying that CSV files with all required metrics are generated.

**Acceptance Scenarios**:

1. **Given** a VM snapshot for any configuration, **When** I run the benchmark automation script, **Then** all required metrics are measured and logged to CSV
2. **Given** CSV data files from all 4 configurations, **When** I import them into analysis tools, **Then** the data format is consistent and suitable for generating comparative graphs
3. **Given** the automation completes, **When** I review the results, **Then** any measurement failures or anomalies are clearly logged

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
- LaTeX source files using LNCS template (https://github.com/latextemplates/LNCS/archive/main.zip)
- Compiled PDF document (minimum 7 pages)
- Must include comparative graphs
- Screenshots permitted (maximum 25% per page)
- Must pass TurnItIn plagiarism check (≤7% similarity)
- Due: 23 Jan 2026, 21:00

### Functional Requirements

#### Mandatory Measurements (Criteria a-e)

- **FR-001**: System MUST measure recursive folder copy speed (≥1GB) via local network using FTP, SFTP, or equivalent protocol across all 4 configurations
- **FR-002**: System MUST specify and document which network protocol is used for folder copying (e.g., FTP, SFTP, SMB)
- **FR-003**: System MUST measure folder transfer from one device to another over local network, not local disk operations
- **FR-004**: System MUST measure download speed of a remote file (≥100MB) from a long-distance server across all 4 configurations
- **FR-005**: System MUST count the number of running processes in Windows for each configuration using Task Manager or equivalent tool
- **FR-006**: System MUST measure RAM memory consumption at system startup for each configuration
- **FR-007**: System MUST measure operating system startup times using a specialized tool (e.g., BootRacer) for each configuration
- **FR-008**: System MUST perform all measurements consistently across all 4 configurations using identical methodology

#### Additional Measurement Criteria (Bonus - Criterion f)

- **FR-009**: System MUST measure additional performance criterion (f) using sysbench from GitHub for bonus points (maximum 20 points)
- **FR-010**: Sysbench benchmarks MUST include at least one of: CPU performance, memory throughput/latency, or disk I/O (IOPS/throughput)
- **FR-011**: Additional criterion MUST be explained with clear rationale: sysbench provides standardized, reproducible benchmarks that reveal IDS overhead on system resources
- **FR-012**: Sysbench MUST be properly attributed in references section with GitHub repository link

#### VM Configuration & Snapshot Management

- **FR-012**: System MUST support creation and restoration of VM snapshots for each of the 4 configurations
- **FR-013**: System MUST ensure baseline snapshot contains no antivirus or firewall software
- **FR-014**: System MUST verify that selected antivirus is properly installed and active in AV-only and AV+Firewall configurations
- **FR-015**: System MUST verify that selected firewall is properly installed and active in Firewall-only and AV+Firewall configurations
- **FR-016**: System MUST document which specific antivirus product was selected from the provided list
- **FR-017**: System MUST document which specific firewall product was selected from the provided list

#### Data Collection & Analysis

- **FR-018**: System MUST persist all measurement data in structured format (CSV or equivalent) with configuration labels
- **FR-019**: System MUST execute each benchmark test multiple times (3-5 iterations) to ensure statistical consistency
- **FR-020**: System MUST calculate percentage impact/overhead for each metric by comparing each IDS configuration to baseline
- **FR-021**: System MUST generate comparative graphs showing all 4 configurations for each measured criterion
- **FR-022**: System MUST ensure graphs are suitable for inclusion in LaTeX document

#### LaTeX Document Generation

- **FR-023**: System MUST generate LaTeX source using the mandatory LNCS template
- **FR-024**: Document MUST follow scientific paper structure: abstract, introduction, related work, methodology, results, discussion, conclusion, references
- **FR-025**: Document MUST include methodology section describing test setup, VM specifications, software versions, and measurement procedures
- **FR-026**: Document MUST include results section with tables and comparative graphs for all measured criteria
- **FR-027**: Document MUST include discussion/analysis section interpreting the results and explaining performance differences
- **FR-028**: Document MUST include references to relevant academic papers or technical sources
- **FR-029**: Document MUST be at least 7 pages when compiled to PDF
- **FR-030**: Document MAY include screenshots but they must not exceed 25% of any page
- **FR-031**: Document MUST be checked for plagiarism and maintain ≤7% similarity score

#### Network Testing Setup

- **FR-032**: System MUST establish a local network connection between two devices for folder copy testing
- **FR-033**: System MUST have access to a remote server for long-distance file download testing
- **FR-034**: System MUST create or identify a test folder of at least 1GB for network copy testing
- **FR-035**: System MUST create or identify a test file of at least 100MB on a remote server for download testing
- **FR-036**: System MUST ensure consistent network conditions across test runs (or document any variations)

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

#### Mandatory Measurements (Criteria a-e)

- **SC-005**: Folder copy speed (≥1GB via local network) is successfully measured across all 4 configurations using documented protocol (FTP/SFTP/etc.)
- **SC-006**: Remote file download speed (≥100MB from long-distance server) is successfully measured across all 4 configurations
- **SC-007**: Process count is successfully measured and recorded for all 4 configurations
- **SC-008**: RAM consumption at startup is successfully measured and recorded for all 4 configurations  
- **SC-009**: OS boot time is successfully measured using specialized tool (e.g., BootRacer) for all 4 configurations
- **SC-010**: All mandatory measurements show consistent results with variance <10% across 3-5 iterations per configuration

#### Additional Criterion (Bonus Points)

- **SC-011**: Sysbench is successfully installed from GitHub and configured for Windows testing
- **SC-012**: At least one sysbench benchmark type (CPU, memory, or disk I/O) is measured across all 4 configurations with documented results
- **SC-013**: Sysbench results reveal meaningful performance differences between configurations and demonstrate IDS impact on system resources
- **SC-014**: Sysbench methodology, rationale, and results are properly documented in the case study with appropriate attribution

#### Data Analysis & Visualization

- **SC-013**: Percentage impact/overhead is accurately calculated for each criterion by comparing each IDS configuration to baseline
- **SC-014**: Comparative graphs are generated showing all 4 configurations for each measured criterion (a-e plus additional)
- **SC-015**: All graphs are properly formatted and suitable for LaTeX document inclusion
- **SC-016**: All measurement data is available in structured format (CSV) for verification and reproducibility

#### LaTeX Document Deliverable

- **SC-017**: LaTeX source files compile successfully to PDF without errors
- **SC-018**: Compiled PDF document meets minimum 7-page requirement
- **SC-019**: Document uses mandatory LNCS template correctly with proper formatting
- **SC-020**: Document includes all required sections: abstract, introduction, related work, methodology, results, discussion, conclusion, references
- **SC-021**: Methodology section clearly describes test setup, VM specs, software versions, selected AV/firewall products, and measurement procedures
- **SC-022**: Results section includes tables and comparative graphs for all measured criteria
- **SC-023**: Discussion section provides insightful analysis explaining performance differences between configurations
- **SC-024**: Screenshots (if included) do not exceed 25% of any page
- **SC-025**: Document passes TurnItIn plagiarism check with ≤7% similarity score
- **SC-026**: Both PDF and complete LaTeX sources are ready for submission

#### Network Testing Infrastructure

- **SC-027**: Local network connection between two devices is established and functional for folder copy testing
- **SC-028**: Remote server with ≥100MB test file is accessible and functional for download testing
- **SC-029**: Test folder of ≥1GB is created/available for network copy benchmarks
- **SC-030**: Network conditions remain consistent across test runs, or variations are documented

#### Project Completion

- **SC-031**: All deliverables (PDF + LaTeX sources) are ready for submission before deadline (23 Jan 2026, 21:00)
- **SC-032**: Selected antivirus and firewall products are documented in project submission
- **SC-033**: Project meets all academic requirements for maximum grade eligibility (including bonus points from additional criterion)

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

- **Operating System**: Windows 11 (implied from existing test plan)
- **Virtualization**: VM-based testing required for snapshot capability
- **Network Setup**: Must have access to both local network (for folder copy) and remote server (for download test)
- **Test Data**: 1GB folder for local copy, 100MB file on remote server
- **Network Protocol**: Must specify which protocol used (FTP, SFTP, SMB, etc.) - [NEEDS CLARIFICATION]
- **Measurement Tools**: Must document all tools used (BootRacer or equivalent, Task Manager/perfmon, etc.)
- **Bonus Criterion Tool**: sysbench from GitHub (https://github.com/akopytov/sysbench) for CPU/memory/disk I/O benchmarking
- **LaTeX Template**: LNCS template mandatory (https://github.com/latextemplates/LNCS/archive/main.zip)
- **Plagiarism Limit**: Maximum 7% similarity on TurnItIn
- **Document Length**: Minimum 7 pages
- **Deadline**: 23 Jan 2026, 21:00

### Open Questions Requiring Clarification

1. ~~Which antivirus product will be selected?~~ **RESOLVED: Symantec**
2. ~~Which firewall product will be selected?~~ **RESOLVED: OPNsense**
3. **Which network protocol for folder copying?** (FTP, SFTP, SMB, or other? Must be specified in paper)
4. ~~What will be the additional criterion (f)?~~ **RESOLVED: System benchmarking using sysbench from GitHub**
5. **What are the exact VM specifications?** (RAM, CPU cores, disk space - should be documented in methodology)
6. **What remote server will be used for download testing?** (Public file host, university server, or other?)
7. **How many iterations per test?** (3-5 iterations recommended for statistical consistency)

### Reference Materials

- **Testing Criteria Reference**: https://pastebin.com/fnxDqJ7V (illustrative purposes only)
- **LNCS LaTeX Template**: https://github.com/latextemplates/LNCS/archive/main.zip (mandatory)
- **Paper Structure Examples**: https://uvt-ro.academia.edu/CiprianPungila (follow same layout as scientific papers)
- **Sysbench Tool**: https://github.com/akopytov/sysbench (for bonus criterion f - system benchmarking)
