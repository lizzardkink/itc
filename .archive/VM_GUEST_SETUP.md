# Win11 VM Guest Setup Checklist

**VM Name**: Win11  
**Platform**: VirtualBox  
**Base State**: Clean Windows 11 (OS updated, no AV/firewall)

---

## Prerequisites (Already Complete)
- ✅ Windows 11 fully updated
- ✅ Clean snapshot created
- ✅ BootRacer installed and configured

---

## Required Software & Tools

### 1. Measurement Tools
- **BootRacer** ✅ (already installed)
  - Configure export path to shared folder
- **Sysbench** (from GitHub: https://github.com/akopytov/sysbench)
  - Install via WSL: `wsl --install` → `wsl apt install sysbench`
  - OR download Windows binary from releases
- **PowerShell** (built-in, verify version ≥5.1)

### 2. Test Scripts (Copy from Host)
- `AV-Bench\script.ps1` - Application launch test (75 instances)
- `scripts\smb-copy-test.ps1` - SMB network copy benchmark
- `scripts\ftp-download-test.ps1` - FTP download benchmark
- `scripts\process-count-test.ps1` - Process count at startup
- `scripts\ram-startup-test.ps1` - RAM usage at startup
- `scripts\sysbench-wrapper.ps1` - Sysbench automation wrapper

### 3. Network Configuration
- **VirtualBox Network Adapter**: Set to **Bridged Mode** (access QNAP NAS)
- **SMB Share**: Map QNAP NAS (1Gbit LAN) for 1GB folder copy test
- **FTP Client**: Built-in Windows FTP or install FileZilla for DIGI Storage (100MB download test)
- **VirtualBox Shared Folder**: Map Z:\Shared (or similar) for data export to host

---

## Setup Steps

### Phase 1: Shared Folder Configuration
1. In VirtualBox, configure shared folder:
   - Folder Path: `C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\data` (host)
   - Folder Name: `ItC_Data`
   - Options: Auto-mount, Make Permanent
2. Inside VM, map shared folder:
   ```powershell
   net use Z: \\vboxsvr\ItC_Data /persistent:yes
   ```
3. Verify read/write access:
   ```powershell
   echo "Test" > Z:\test.txt
   cat Z:\test.txt
   ```

### Phase 2: Network Setup
4. Set VirtualBox network adapter to **Bridged Mode**
5. Map QNAP NAS share for SMB test:
   ```powershell
   net use N: \\QNAP_IP\ShareName /user:username password
   ```
6. Verify 1GB test folder exists on QNAP NAS (or create one)
7. Configure FTP connection to DIGI Storage (verify 100MB test file exists)

### Phase 3: Tool Installation
8. Install WSL for sysbench:
   ```powershell
   wsl --install
   # After reboot:
   wsl apt update && wsl apt install sysbench -y
   ```
   OR download sysbench Windows binary from GitHub releases
9. Copy all test scripts from host to VM:
   ```powershell
   Copy-Item "Z:\scripts\*.ps1" -Destination "C:\Benchmarks\" -Recurse
   Copy-Item "Z:\AV-Bench\script.ps1" -Destination "C:\Benchmarks\app-launch-test.ps1"
   ```

### Phase 4: Tool Verification
10. Verify BootRacer export path points to shared folder (Z:\data\boot-times\)
11. Test application launch script:
    ```powershell
    cd C:\Benchmarks
    .\app-launch-test.ps1 -ConfigName "test" -Iterations 1
    ```
12. Test sysbench:
    ```powershell
    wsl sysbench cpu --threads=4 --time=10 run
    ```
13. Verify all scripts can write to Z:\Shared folder

### Phase 5: Snapshot Creation
14. **Shutdown VM cleanly**
15. Take snapshot: **"Baseline-NoIDS"**
16. Install Symantec Antivirus → snapshot: **"Symantec-Only"**
17. Restore to Baseline → Install OPNsense Firewall → snapshot: **"OPNsense-Only"**
18. Restore to Baseline → Install both → snapshot: **"Symantec-OPNsense-Both"**

---

## Test Execution Order (Per Configuration)

Run 5 iterations of each test, saving results to Z:\Shared:

### A. Boot Time (BootRacer)
- Reboot 5 times, BootRacer auto-exports to Z:\data\boot-times\

### B. RAM Usage at Startup
```powershell
.\ram-startup-test.ps1 -ConfigName "baseline" -Iterations 5
```

### C. Process Count
```powershell
.\process-count-test.ps1 -ConfigName "baseline" -Iterations 5
```

### D. SMB Folder Copy (1GB to QNAP NAS)
```powershell
.\smb-copy-test.ps1 -ConfigName "baseline" -Iterations 5
```

### E. FTP Download (100MB from DIGI Storage)
```powershell
.\ftp-download-test.ps1 -ConfigName "baseline" -Iterations 5
```

### F. Application Launch Test (75 instances)
```powershell
.\app-launch-test.ps1 -ConfigName "baseline" -Iterations 5
```

### G. Sysbench (CPU/Memory/Disk)
```powershell
.\sysbench-wrapper.ps1 -ConfigName "baseline" -Iterations 5
```

---

## Data Export

All measurement files automatically save to **Z:\Shared** (VirtualBox shared folder).

From host computer, access results at:
```
C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\data\
```

---

## Notes
- Disable Windows Update during testing to prevent interruptions
- Disable power saving / sleep mode
- Run tests at same time of day for consistency
- Ensure no other applications running during benchmarks
- Document exact Symantec and OPNsense versions installed
- Keep network stable (no downloads/uploads on host during tests)

---

**Generated**: 2026-01-16
