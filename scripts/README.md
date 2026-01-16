# Scripts Directory

PowerShell automation scripts for IDS testing.

## Test Scripts

- **smb-copy-test.ps1**: Measures SMB network copy speed (1GB folder to QNAP NAS)
- **ftp-download-test.ps1**: Measures FTP download speed (100MB from DIGI Storage)
- **process-count-test.ps1**: Counts running processes at Windows startup
- **ram-startup-test.ps1**: Measures RAM usage at Windows startup
- **sysbench-wrapper.ps1**: Wrapper for sysbench CPU/memory/disk benchmarks

## Usage

All scripts accept parameters and export CSV results:

```powershell
.\smb-copy-test.ps1 -ConfigName "baseline" -Iterations 5
```

Output files are saved to corresponding data subdirectories.

Generated: 2026-01-16 16:22:08
