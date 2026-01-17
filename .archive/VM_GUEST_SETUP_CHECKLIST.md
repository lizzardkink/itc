# VM Guest Setup Checklist

**VM Name**: Win11  
**Purpose**: IDS Impact Analysis Research  
**Snapshot**: Clean baseline with BootRacer installed

## Required Software Installations

### Pre-installed (Already Done)
- [x] Windows 11 (up to date)
- [x] BootRacer (for boot time measurements)

### Network Setup
- [ ] Map Z: drive to host shared folder: `\\VBOXSVR\VMShare` or `C:\VMShare`
  ```cmd
  net use Z: \\VBOXSVR\VMShare /persistent:yes
  ```
- [ ] Map network share: `net use N: \\192.168.50.99\Public\Test /persistent:yes`
- [ ] Verify FTP access to DIGI Storage (FileZilla already configured on host)

### Testing Tools Required

#### BootRacer
- [x] Already installed
- [ ] Verify it runs automatically on boot
- [ ] Configure to save logs to Z:\data\<config>\boot-time-<config>.csv

#### Application Launch Test
- [ ] Copy AV-Bench/script.ps1 to VM (e.g., C:\Benchmarks\)
- [ ] Verify PowerShell execution policy allows scripts:
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
- [ ] Test run: `.\script.ps1` (should launch 125 apps over 5 iterations)
- [ ] Verify measurements.csv is created

#### Process & RAM Monitoring
- [ ] Task Manager available (built-in)
- [ ] Create process count script: `scripts\process-count-test.ps1`
- [ ] Create RAM monitoring script: `scripts\ram-startup-test.ps1`
- [ ] Save results to Z:\data\<config>\

#### Network Transfer Tests
- [ ] Create SMB copy test script: `scripts\smb-copy-test.ps1`
  - Source: N:\ (192.168.50.99:/Public/Test)
  - Target: C:\Temp\ (local VM disk)
  - Size: ≥1GB
  - Iterations: 5
  - Output: Z:\data\<config>\smb-copy-<config>.csv

- [ ] Create FTP download script: `scripts\ftp-download-test.ps1`
  - Source: DIGI Storage FTP server
  - Target: C:\Temp\
  - Size: ≥100MB
  - Iterations: 5
  - Output: Z:\data\<config>\ftp-download-<config>.csv

#### Optional: Sysbench (Bonus Points)
- [ ] Install WSL: `wsl --install`
- [ ] Reboot if required
- [ ] Install sysbench in WSL:
  ```bash
  sudo apt-get update
  sudo apt-get install sysbench
  ```
- [ ] Create wrapper script: `scripts\sysbench-wrapper.ps1`
- [ ] Save results to Z:\data\<config>\sysbench-<config>.csv

### IDS Software Installation (Per Configuration)

#### Configuration 1: Baseline (No IDS)
- [x] Clean Windows 11 - no antivirus or firewall beyond Windows Defender (disabled)
- Snapshot name: `Baseline-NoIDS`

#### Configuration 2: Symantec Only
- [ ] Restore Baseline-NoIDS snapshot
- [ ] Install Symantec Endpoint Protection
- [ ] Update virus definitions
- [ ] Verify real-time protection enabled
- [ ] Create snapshot: `Symantec-Only`

#### Configuration 3: OPNsense Only
- [ ] Restore Baseline-NoIDS snapshot
- [ ] Configure Windows Firewall with Advanced Security (or install OPNsense client if available)
- [ ] Enable firewall rules
- [ ] Verify firewall active
- [ ] Create snapshot: `OPNsense-Only`

#### Configuration 4: Both
- [ ] Restore Baseline-NoIDS snapshot
- [ ] Install Symantec Endpoint Protection
- [ ] Configure Windows Firewall (or OPNsense)
- [ ] Verify both active simultaneously
- [ ] Create snapshot: `Symantec-OPNsense-Both`

## Data Collection Workflow

### For Each Configuration:

1. **Restore snapshot** (e.g., Baseline-NoIDS)

2. **Boot Time Test** (5 iterations)
   - Reboot VM 5 times
   - BootRacer records boot time automatically
   - Copy results to Z:\data\<config>\boot-time-<config>.csv

3. **RAM Usage Test** (5 iterations)
   - Run at startup: `.\scripts\ram-startup-test.ps1`
   - Output: Z:\data\<config>\ram-startup-<config>.csv

4. **Process Count Test** (5 iterations)
   - Run at startup: `.\scripts\process-count-test.ps1`
   - Output: Z:\data\<config>\process-count-<config>.csv

5. **SMB Copy Test** (5 iterations)
   - Run: `.\scripts\smb-copy-test.ps1 -ConfigName <config> -Iterations 5`
   - Output: Z:\data\<config>\smb-copy-<config>.csv

6. **FTP Download Test** (5 iterations)
   - Run: `.\scripts\ftp-download-test.ps1 -ConfigName <config> -Iterations 5`
   - Output: Z:\data\<config>\ftp-download-<config>.csv

7. **Application Launch Test** (5 iterations)
   - Run: `.\AV-Bench\script.ps1`
   - Copy measurements.csv to Z:\data\<config>\app-launch-<config>.csv

8. **Optional: Sysbench Test** (5 iterations)
   - Run: `.\scripts\sysbench-wrapper.ps1 -ConfigName <config> -Iterations 5`
   - Output: Z:\data\<config>\sysbench-<config>.csv

## Verification Checklist

After all tests completed:

### Data Files Check
- [ ] data/baseline/ contains 6-7 CSV files (7 if sysbench included)
- [ ] data/symantec/ contains 6-7 CSV files
- [ ] data/opnsense/ contains 6-7 CSV files
- [ ] data/both/ contains 6-7 CSV files

### Data Quality Check
- [ ] Each CSV has 5 data rows (iterations)
- [ ] No missing values
- [ ] Variance <10% within each configuration
- [ ] Timestamps are correct

### Snapshot Check
- [ ] Baseline-NoIDS snapshot exists and works
- [ ] Symantec-Only snapshot exists and works
- [ ] OPNsense-Only snapshot exists and works
- [ ] Symantec-OPNsense-Both snapshot exists and works

## Network Configuration Details

### Host Configuration
- **Shared Folder**: C:\VMShare (on host)
- **Guest Mapping**: Z: drive (in VM)

### Guest Network Configuration
- **Adapter Mode**: Bridged Adapter
- **Network Share**: \\192.168.50.99\Public\Test (mapped as N:)
- **Connection**: 1 Gigabit LAN
- **FTP Server**: DIGI Storage (configured via FileZilla on host)

### Test Data Locations
- **SMB Test Data**: N:\<1GB folder> (192.168.50.99:/Public/Test)
- **FTP Test Data**: DIGI Storage FTP server (≥100MB file)
- **Local Temp**: C:\Temp\ (for download targets)

## PowerShell Scripts Required

Create these scripts in `C:\Benchmarks\scripts\` on the guest VM:

1. **process-count-test.ps1** - Count running processes
2. **ram-startup-test.ps1** - Measure RAM usage at startup
3. **smb-copy-test.ps1** - Measure SMB copy speed
4. **ftp-download-test.ps1** - Measure FTP download speed
5. **sysbench-wrapper.ps1** (optional) - Run sysbench tests

All scripts should:
- Accept `-ConfigName` and `-Iterations` parameters
- Output CSV to Z:\data\$ConfigName\
- Include timestamps
- Handle errors gracefully

## Testing Order

Recommended testing order to maximize efficiency:

1. **Baseline** (Day 1-2)
2. **Symantec-Only** (Day 3-4)
3. **OPNsense-Only** (Day 5-6)
4. **Both** (Day 7)

Total test runs per configuration: 6-7 criteria × 5 iterations = 30-35 runs
Total test runs for project: 4 configs × 30-35 runs = **120-140 runs**

## Notes

- Always restore snapshot before testing a new configuration
- Wait 2-3 minutes after boot before starting tests
- Ensure no background updates are running during tests
- Keep network conditions consistent
- Document any anomalies or deviations

## Contact & Support

If issues arise:
- Check VM_SETUP_GUIDE.md for VirtualBox issues
- Check NETWORK_TEST_CONFIG.md for SMB issues
- Check REMOTE_DOWNLOAD_CONFIG.md for FTP issues
- Check PROJECT_STATUS.md for overall progress

**Last Updated**: 2026-01-16
