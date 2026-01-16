# Data Directory

This directory contains all test results from the IDS performance impact analysis.

## Structure

- **baseline/**: Results from configuration with no IDS (clean Windows 11)
- **symantec/**: Results from configuration with Symantec Endpoint Protection only
- **opnsense/**: Results from configuration with OPNsense firewall only
- **both/**: Results from configuration with both Symantec + OPNsense

## File Naming Convention

Each CSV file follows the pattern: <criterion>-<config>.csv

Example files per configuration:
- smb-copy-baseline.csv - SMB network copy test (criterion a)
- tp-download-baseline.csv - FTP remote download test (criterion b)
- process-count-baseline.csv - Process count at startup (criterion c)
- am-startup-baseline.csv - RAM usage at startup (criterion d)
- oot-time-baseline.csv - Boot time measurement (criterion e)
- sysbench-cpu-baseline.csv - Sysbench CPU benchmark (criterion f)
- sysbench-memory-baseline.csv - Sysbench memory benchmark (criterion f)
- sysbench-disk-baseline.csv - Sysbench disk I/O benchmark (criterion f)
- pp-launch-baseline.csv - Application launch performance (criterion g)

## Data Format

All CSV files include:
- Timestamps
- Iteration number (1-5)
- Measurement value
- Units

## Usage

Data from this directory will be:
1. Imported for statistical analysis
2. Used to calculate overhead percentages
3. Visualized in comparative graphs
4. Included in LaTeX paper results section

Generated: 2026-01-16 16:22:08
