# IDS Impact Analysis Research Project Constitution

## Core Principles

### I. Academic Integrity & Reproducibility

All research activities must maintain the highest standards of academic integrity. Every benchmark, measurement, and analysis must be:
- **Reproducible**: Documented with sufficient detail for independent verification
- **Honest**: Report all results accurately, including anomalies or unexpected outcomes
- **Original**: Written content must pass plagiarism checks (≤7% similarity on TurnItIn)
- **Attributed**: All tools, methods, and references properly cited

### II. Systematic Methodology

Research must follow a rigorous, consistent methodology across all test configurations:
- **Identical Procedures**: All 4 configurations (No IDS, AV-only, Firewall-only, AV+Firewall) tested using identical methods
- **Statistical Validity**: Minimum 3-5 iterations per test to ensure consistency (variance <10%)
- **Controlled Environment**: VM snapshots ensure repeatable, clean test states
- **Documentation First**: Methodology must be documented before execution begins

### III. Data-Driven Analysis

All conclusions must be supported by empirical data and comparative analysis:
- **Quantitative Metrics**: Every criterion measured with specific units and timestamps
- **Comparative Graphs**: Visual evidence showing all 4 configurations for each metric
- **Percentage Calculations**: Overhead computed relative to baseline (No IDS)
- **Structured Storage**: All raw data persisted in CSV format for verification

### IV. Mandatory Requirements Compliance

The project must meet all academic requirements specified in the assignment:
- **5 Mandatory Criteria**: (a) network folder copy ≥1GB, (b) remote download ≥100MB, (c) process count, (d) RAM at startup, (e) boot time
- **Bonus Criterion**: At least one additional criterion (f) with documented rationale
- **LaTeX Format**: LNCS template mandatory, minimum 7 pages
- **Deadline Adherence**: All deliverables ready before 23 Jan 2026, 21:00

### V. Product Selections & Configuration Integrity

Selected security products must be properly installed and verified:
- **Antivirus**: Symantec (selected from approved list)
- **Firewall**: OPNsense (selected from approved list)
- **Verification**: Confirm active status in respective configurations
- **Isolation**: Baseline configuration must have no IDS software

## Testing Standards

### Measurement Quality

All measurements must meet quality standards:
- **Consistency**: Results within 10% variance across iterations
- **Completeness**: All 4 configurations tested for every criterion
- **Timestamps**: Every measurement logged with date/time
- **Units**: All values recorded with appropriate units (seconds, MB, count, etc.)

### Network Testing Requirements

Network-based tests require proper infrastructure:
- **Local Network**: Two devices connected for 1GB folder copy test
- **Protocol Specification**: Document which protocol used (FTP/SFTP/SMB/etc.)
- **Remote Server**: Long-distance server accessible for 100MB download test
- **Network Conditions**: Document any variations in network performance

### VM Environment Standards

Virtual machine testing environment must be:
- **Snapshot-Based**: Clean snapshots for each configuration
- **Specified**: VM specs (RAM, CPU, disk) documented in methodology
- **Windows-Based**: Windows OS (implied from requirements)
- **Isolated**: No interference from host system or other processes
- **Target System**: All information gathering, measurements, and BootRacer data retrieval targets the VM (WIN11), not the host machine

## LaTeX Document Standards

### Structure Requirements

The case study must follow scientific paper structure:
- **Abstract**: Concise summary of research and findings
- **Introduction**: Problem statement and research objectives
- **Related Work**: Brief review of relevant literature
- **Methodology**: Detailed description of test setup and procedures
- **Results**: Tables and graphs showing all measurements
- **Discussion**: Analysis and interpretation of findings
- **Conclusion**: Summary of impact and implications
- **References**: Properly cited sources

### Documentation Workflow

All content destined for LaTeX must follow this workflow:
- **Stage 1 - Aggregation**: All documentation aggregated to `paper.md` for review
- **Stage 2 - Review**: User reviews and approves `paper.md` content
- **Stage 3 - LaTeX Conversion**: Only after approval, content converted to LaTeX format
- **Stage 4 - PDF Generation**: Final compilation to PDF for submission

**Critical**: LaTeX and PDF conversion only happens AFTER user approval of paper.md

### Formatting Rules

LaTeX document must comply with:
- **Template**: LNCS template from https://github.com/latextemplates/LNCS/archive/main.zip
- **Length**: Minimum 7 pages when compiled to PDF
- **Screenshots**: Maximum 25% of any page
- **Compilation**: Must compile without errors
- **Readability**: Clear, professional academic writing

### Content Quality

Written content must meet academic standards:
- **Plagiarism**: ≤7% similarity on TurnItIn
- **Clarity**: Technical concepts explained clearly
- **Accuracy**: All data and claims verified against measurements
- **Insight**: Discussion provides meaningful analysis, not just data presentation

## Project Management

### Timeline Adherence

The project has a hard deadline:
- **Deadline**: 23 Jan 2026, 21:00
- **Buffer**: Build in time for LaTeX compilation issues, graph generation, plagiarism checks
- **Checkpoints**: Regular progress verification against specification
- **Risk Management**: Identify blockers early (network access, software installation, etc.)

### Configuration Management

Proper management of test configurations:
- **Snapshot Discipline**: Always restore from clean snapshots
- **No Cross-Contamination**: Never modify baseline after other installations
- **Version Tracking**: Document software versions for Symantec and OPNsense
- **State Verification**: Confirm configuration state before each test run

### Data Management

All research data must be properly managed:
- **CSV Storage**: Structured data files for all measurements
- **Backup**: Data backed up to prevent loss
- **Labeling**: Clear labels for configuration (NoIDS/AV/FW/Both)
- **Iteration Tracking**: Each test run numbered and timestamped

## Governance

This constitution establishes non-negotiable standards for the research project. All benchmarking, analysis, and documentation activities must comply with these principles.

**Conflicts**: If any contradiction arises between this constitution and other project documents, this constitution takes precedence.

**Amendments**: This constitution may be amended only if academic requirements change or if amendments improve research quality without compromising integrity.

**Compliance**: Every measurement, graph, and written paragraph must be traceable back to these principles.

**Deliverables**: Final submission includes PDF + LaTeX sources, both complying with all standards herein.

---

**Version**: 1.0.0 | **Ratified**: 2026-01-16 | **Last Amended**: 2026-01-16
