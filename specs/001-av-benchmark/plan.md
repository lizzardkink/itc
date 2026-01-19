# Implementation Plan: IDS Impact Analysis Research

**Branch**: `001-av-benchmark` | **Date**: 2026-01-16 15:49 UTC | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/001-av-benchmark/spec.md`

**Note**: This is an academic research project with 4-variant IDS testing and LaTeX paper deliverable.

**Test Criteria (Reordered)**:
- **Criterion A**: OS boot time (BootRacer)
- **Criterion B**: RAM at startup
- **Criterion C**: Process count at startup
- **Criterion D**: Application launch performance (AV-Bench/script.ps1 - 30 apps per iteration)
- **Criterion E**: Local network SMB copy (1GB to 192.168.50.99/Public/Test)
- **Criterion F**: Remote FTP download (100MB from DIGI Storage)

**Configuration**:
- Antivirus: TotalAV (6.5.219)
- Firewall: Fort Firewall (3.19.9)
- VM: Win11 (VirtualBox), BootRacer installed
- Network: SMB to QNAP 192.168.50.99/Public/Test, FTP to DIGI Storage (FileZilla)
- Shared folder: Host C:\VMShare → Guest Z:
- Iterations: 5 per test (150 total app launches for Criterion D)

## Summary

This project analyzes the performance impact of intrusion detection systems (antivirus and firewall) on Windows 11 computational resources through systematic benchmarking. Four configurations (No IDS, TotalAV-only, Fort Firewall-only, Both) will be measured across six performance criteria (boot time, RAM usage, process count, application launch performance, local network transfer speed, and remote download speed) with results documented in a 7+ page LNCS-formatted LaTeX paper including 3 testing methodology references from Tom's Hardware/AnandTech. The research compares baseline performance against IDS-enabled configurations to quantify overhead percentages, with findings submitted by January 23, 2026.

## Technical Context

**Platform**: Windows 11 (64-bit) in VirtualBox VM  
**VM Configuration**: WIN11 VM with 4 CPU cores, 8 GB RAM, SATA storage  
**Virtualization**: Oracle VirtualBox with snapshot-based testing  
**IDS Software**: TotalAV (6.5.219) + Fort Firewall (3.19.9)  
**Testing Tools**: BootRacer, PowerShell scripts, Windows Performance Monitor, AV-Bench/script.ps1 
**Network Infrastructure**: 1 Gigabit LAN to QNAP NAS (192.168.50.99), FTP to DIGI Storage  
**Shared Folder**: C:\VMShare on host mapped to Z: drive in guest for automated data collection  
**Data Format**: CSV for measurements, LaTeX for paper  
**Document Format**: LNCS LaTeX template (7+ pages minimum)  
**Plagiarism Check**: TurnItIn (≤7% similarity required)  
**Performance Goals**: Measurement variance <10% across 5 iterations  
**Constraints**: 7-day deadline (23 Jan 2026, 21:00), academic integrity (no plagiarism)  
**Scale**: 120 total test runs (4 configs × 6 criteria × 5 iterations)

## Constitution Check

*GATE: Academic integrity and systematic methodology requirements.*

**Constitution Compliance**:
- ✅ **Academic Integrity**: All measurements will be original, reproducible, and properly attributed
- ✅ **Systematic Methodology**: Identical procedures across all 4 configurations with 5 iterations each
- ✅ **Data-Driven**: CSV storage for all measurements, comparative graphs required
- ✅ **Requirements Compliance**: All mandatory criteria (a-e) + bonus criterion (f) specified
- ✅ **Product Selection**: TotalAV 6.5.219 (AV) + Fort Firewall 3.19.9 (firewall) confirmed
- ✅ **Statistical Validity**: 5 iterations per test, variance target <10%
- ✅ **LaTeX Standards**: LNCS template, 7+ pages, ≤7% plagiarism
- ✅ **Timeline**: 7-day deadline with structured testing phases

**No violations detected. Ready to proceed.**

## Project Structure

### Documentation (this feature)

```text
specs/001-av-benchmark/
├── spec.md              # Feature specification (complete)
├── plan.md              # This implementation plan
└── tasks.md             # Task breakdown (to be created)

Root documentation:
├── VM_SETUP_GUIDE.md          # VirtualBox snapshot management
├── VM_SPECS.md                # VM hardware specifications
├── NETWORK_TEST_CONFIG.md     # SMB testing procedures
├── REMOTE_DOWNLOAD_CONFIG.md  # FTP testing procedures
├── LATEX_SETUP_TODO.md        # LaTeX template setup
├── sysbench.txt               # sysbench installation notes
└── .specify/memory/ids-research-constitution.md  # Project principles
```

### Research Data & Scripts (repository root)

```text
AV-Bench/                    # Existing benchmark resources
├── test-plan-*             # Original test planning documents
└── task-list-*             # Original task lists

data/                        # Measurement data (to be created)
├── baseline/
│   ├── boot-time-*.csv
│   ├── ram-startup-*.csv
│   ├── process-count-*.csv
│   ├── app-launch-*.csv
│   ├── smb-copy-*.csv
│   └── ftp-download-*.csv
├── symantec/
│   └── [same structure]
├── opnsense/
│   └── [same structure]
└── both/
    └── [same structure]

scripts/                     # Testing automation (to be created)
├── boot-time-test.ps1
├── ram-startup-test.ps1
├── process-count-test.ps1
├── smb-copy-test.ps1
└── ftp-download-test.ps1

lncs-enhanced-main/          # LaTeX paper (exists)
├── paper.tex                # Main document (to be edited)
├── paper.bib                # References (to be populated)
├── llncs.cls                # LNCS class (installed)
├── figures/                 # Graphs (to be generated)
└── paper.pdf                # Output (to be compiled)
```

**Structure Decision**: Research project structure focused on data collection, analysis, and academic paper generation. No traditional software development - this is a measurement and documentation project with PowerShell scripts for automation.

## Complexity Tracking

> No complexity violations. This is a straightforward research project with well-defined scope.

**Complexity is appropriate because**:
- 4 configurations required by academic assignment (not over-engineering)
- 6 criteria mandatory (5 required + 1 bonus for maximum grade)
- 5 iterations needed for statistical validity
- LaTeX format mandated by course requirements
- All tools and methods standard for performance research

## Implementation Phases

### Phase 0: Environment Setup (Day 1)
**Goal**: Prepare VM snapshots and testing infrastructure

**Tasks**:
1. Rename WIN11 VM snapshot 'Clean' → 'Baseline-NoIDS'
2. Configure VM network to Bridged mode for QNAP access
3. Configure VirtualBox shared folder (C:\VMShare on host → Z: drive in guest)
4. Verify SMB access to QNAP NAS (192.168.50.99:/Public/Test)
5. Verify FTP access to DIGI Storage
6. Verify BootRacer is installed for boot time measurement
7. Create 1GB test folder on QNAP NAS
8. Upload 100MB test file to DIGI Storage

**Deliverables**:
- Baseline-NoIDS snapshot verified
- Shared folder mapping configured and tested
- Network connectivity confirmed (SMB and FTP)
- All testing tools verified
- Test data prepared

### Phase 1: Baseline Measurements (Days 1-2)
**Goal**: Collect baseline data from clean Windows 11 (no IDS)

**Tasks**:
1. Restore Baseline-NoIDS snapshot
2. Run boot time test with BootRacer (5 iterations) → save to Z:\data\baseline\boot-time-*.csv
3. Measure RAM at startup (5 boots) → save to Z:\data\baseline\ram-startup-*.csv
4. Count processes (5 boots) → save to Z:\data\baseline\process-count-*.csv
5. Run application launch test with AV-Bench/script.ps1 (5 iterations) → save to Z:\data\baseline\app-launch-*.csv
6. Run SMB copy test (5 iterations) → save to Z:\data\baseline\smb-copy-*.csv
7. Run FTP download test (5 iterations) → save to Z:\data\baseline\ftp-download-*.csv

**Deliverables**:
- 6 CSV files with baseline measurements (all criteria A-F)
- Variance verification (<10% required)

### Phase 2: TotalAV Configuration (Days 3-4)
**Goal**: Install TotalAV and measure performance impact

**Tasks**:
1. Restore Baseline-NoIDS snapshot
2. Install TotalAV (6.5.219)
3. Update antivirus definitions
4. Verify real-time protection is active
5. Create 'TotalAV-Only' snapshot
6. Run all 6 criteria tests (5 iterations each) → save to Z:\data\antivirus\

**Deliverables**:
- TotalAV-Only snapshot
- 6 CSV files with AV measurements

### Phase 3: Fort Firewall Configuration (Days 5-6)
**Goal**: Install Fort Firewall and measure performance impact

**Tasks**:
1. Restore Baseline-NoIDS snapshot
2. Install Fort Firewall (3.19.9)
3. Enable firewall rules and logging
4. Verify firewall is active
5. Create 'FortFirewall-Only' snapshot
6. Run all 6 criteria tests (5 iterations each) → save to Z:\data\firewall\

**Deliverables**:
- FortFirewall-Only snapshot
- 6 CSV files with firewall measurements

### Phase 4: Combined Configuration (Day 7)
**Goal**: Install both IDS components and measure combined impact

**Tasks**:
1. Restore Baseline-NoIDS snapshot
2. Install TotalAV (6.5.219)
3. Install Fort Firewall (3.19.9)
4. Verify both are active simultaneously
5. Create 'TotalAV-FortFirewall-Both' snapshot
6. Run all 6 criteria tests (5 iterations each) → save to Z:\data\both\

**Deliverables**:
- TotalAV-FortFirewall-Both snapshot
- 6 CSV files with combined measurements

### Phase 5: Data Analysis (Days 8-9)
**Goal**: Calculate overhead and generate comparative visualizations

**Tasks**:
1. Import all CSV data (24 files total: 6 criteria × 4 configurations)
2. Calculate average, min, max for each test
3. Calculate percentage overhead vs baseline
4. Generate comparative graphs (6 graphs, one per criterion: A-F)
5. Export graphs to `lncs-enhanced-main/figures/`
6. Verify statistical significance

**Deliverables**:
- Overhead calculations for all 6 criteria
- 6 publication-ready graphs
- Statistical analysis summary

### Phase 6: LaTeX Paper Writing (Days 10-13)
**Goal**: Write and compile 7+ page LNCS-formatted paper

**Tasks**:
1. Write Abstract (problem, method, findings)
2. Write Introduction (context, objectives)
3. Write Related Work (literature review with 3 Tom's Hardware/AnandTech references)
4. Write Methodology (4 configs, 6 criteria, VM specs, tools, shared folder setup)
5. Write Results (tables with measurements, graphs)
6. Write Discussion (analysis of overhead patterns)
7. Write Conclusion (summary, implications)
8. Populate References section (include testing methodology webpages)
9. Insert figures and tables
10. Compile to PDF (`latexmk paper` or `lualatex paper`)
11. Check plagiarism with TurnItIn (must be ≤7%)
12. Final proofreading and formatting

**Deliverables**:
- Complete LaTeX source (paper.tex, paper.bib)
- Compiled PDF (7+ pages)
- Plagiarism report (≤7%)
- Ready for submission

### Phase 7: Final Review & Submission (Day 14)
**Goal**: Ensure all requirements met and submit on time

**Tasks**:
1. Verify PDF is 7+ pages
2. Verify all 6 criteria documented
3. Verify comparative graphs included
4. Verify LNCS format compliance
5. Verify references are complete (including 3 Tom's Hardware/AnandTech)
6. Final plagiarism check
7. Package: PDF + LaTeX sources
8. Submit before deadline (23 Jan 2026, 21:00)

**Deliverables**:
- Final submission package
- Confirmation of submission

## Risk Management

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| VM snapshot corruption | Low | High | Regular backups, test restore before each use |
| Network connectivity issues | Medium | Medium | Test connectivity before each session, document downtime |
| TotalAV installation fails | Medium | High | Have alternative AV ready, document actual product used |
| Fort Firewall incompatibility | Low | High | Use Windows Firewall as documented alternative |
| Inconsistent measurements (>10% variance) | Medium | Medium | Increase iterations to 7-10 if needed |
| LaTeX compilation errors | Low | Medium | Test compile early, LNCS template already verified |
| Plagiarism check fails | Low | Critical | Use own words, proper citations, check iteratively |
| Miss deadline | Low | Critical | Daily progress tracking, buffer time built in |

## Success Criteria

**Measurements Complete**:
- ✅ 120 test runs executed (4 configs × 6 criteria × 5 iterations)
- ✅ All data in CSV format with timestamps
- ✅ Variance <10% within iterations
- ✅ All 4 VM snapshots functional and verified
- ✅ Shared folder data collection working properly

**Analysis Complete**:
- ✅ Overhead percentages calculated for all 6 criteria
- ✅ 6 comparative graphs generated (criteria a-f)
- ✅ Statistical validity confirmed

**Paper Complete**:
- ✅ 7+ pages in LNCS format
- ✅ All sections present (abstract through references)
- ✅ Bibliography includes 3 Tom's Hardware/AnandTech methodology references
- ✅ Plagiarism ≤7%
- ✅ Compiles without errors
- ✅ Submitted before deadline (23 Jan 2026, 21:00)

## Timeline Summary

| Days | Phase | Deliverable |
|------|-------|-------------|
| 1 | Setup | Environment ready |
| 1-2 | Baseline | Baseline data collected |
| 3-4 | TotalAV | AV data collected |
| 5-6 | Fort Firewall | Firewall data collected |
| 7 | Combined | Both IDS data collected |
| 8-9 | Analysis | Graphs and calculations |
| 10-13 | Writing | LaTeX paper complete |
| 14 | Submission | Submitted on time |

**Total**: 14 days (7 days buffer from specification complete to deadline)
