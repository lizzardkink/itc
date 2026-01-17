# VM Guest Setup Requirements (WIN11 VM)

**VM Name**: Win11  
**Baseline Snapshot**: Clean state with OS up to date, no antivirus or firewall installed  
**Last Updated**: 2026-01-16

## ✅ Already Configured

1. **BootRacer** - Already installed for boot time measurements
2. **Baseline Snapshot** - VM has clean snapshot ready
3. **Windows 11** - OS is up to date

## 📋 Required Setup Tasks

### 1. Shared Folder Mapping

**Host Side**:
- Shared folder path: `C:\VMShare` (on host computer)

**Guest Side** (inside Win11 VM):
- Map shared folder to drive letter: **Z:**
- Configure as persistent mapping (reconnect at logon)
- Verify read/write permissions

**Verification Commands** (run in VM):
```powershell
# Check if Z: drive is mapped
Test-Path Z:\
# Test write permissions
"test" | Out-File Z:\test.txt
Get-Content Z:\test.txt
Remove-Item Z:\test.txt
```

**Configuration Steps**:
1. Open VirtualBox Manager
2. Select WIN11 VM → Settings → Shared Folders
3. Add Shared Folder:
   - Folder Path: `C:\VMShare`
   - Folder Name: `VMShare`
   - Check: Auto-mount
   - Check: Make Permanent
4. Boot VM
5. In VM, open PowerShell as Administrator:
```powershell
# Map the shared folder to Z: drive
net use Z: \\VBOXSVR\VMShare /persistent:yes
```

---

### 2. Network Share Mapping (QNAP NAS)

**Network Share Details**:
- Server: `192.168.50.99`
- Share Path: `/Public/Test`
- Protocol: SMB (Server Message Block)
- Connection: 1 Gigabit LAN

**Required Setup**:
1. Map network share to drive letter (e.g., **N:** for Network)
2. Configure as persistent mapping
3. Verify 1GB test folder is accessible

**Configuration Steps** (run in VM):
```powershell
# Map network share to N: drive
net use N: \\192.168.50.99\Public\Test /persistent:yes

# Verify access
Test-Path N:\
Get-ChildItem N:\
```

---

### 3. FTP Access Configuration (DIGI Storage)

**FTP Server Details**:
- Server: DIGI Storage (IP/hostname as configured)
- Protocol: FTP
- Tool: FileZilla (or built-in Windows FTP client)

**Required Setup**:
1. Install FileZilla Client (if using GUI) **OR** use PowerShell built-in FTP
2. Configure FTP connection settings
3. Test file download (100MB+ test file should be available)

**Configuration Steps** (PowerShell method):
```powershell
# Test FTP connectivity
$ftpServer = "ftp://digi-storage-server/"
$ftpUser = "username"
$ftpPass = "password"

# Create credentials
$ftpRequest = [System.Net.FtpWebRequest]::Create($ftpServer)
$ftpRequest.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
$ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory

# Test connection
$response = $ftpRequest.GetResponse()
$response.StatusDescription
$response.Close()
```

**FileZilla Method**:
1. Install FileZilla Client
2. Site Manager → New Site
3. Protocol: FTP
4. Host: [DIGI Storage IP/hostname]
5. User: [your username]
6. Password: [your password]
7. Test connection

---

### 4. Windows Performance Monitor Setup

**Required for**:
- RAM usage measurements at startup
- Process count measurements

**Configuration Steps**:
1. Open Performance Monitor (`perfmon`)
2. Configure data collectors (if needed)
3. Verify access to performance counters

**Test Commands**:
```powershell
# Test process counting
Get-Process | Measure-Object | Select-Object Count

# Test RAM measurement
Get-CimInstance Win32_OperatingSystem | Select-Object @{
    Name='UsedRAM_MB';
    Expression={[math]::Round(($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)/1KB,2)}
}
```

---

### 5. Test Scripts Deployment

**Location**: All test scripts should be stored on **Z: drive** for easy access from host

**Required Scripts**:
1. `smb-copy-test.ps1` - SMB network copy test
2. `ftp-download-test.ps1` - FTP download speed test
3. `process-count-test.ps1` - Process counting script
4. `ram-startup-test.ps1` - RAM measurement script
5. `AV-Bench\script.ps1` - Application launch test (already exists)

**Script Output**: All scripts should save results to **Z: drive** for automatic collection on host

---

### 6. Network Adapter Configuration

**VirtualBox Settings**:
- Network Adapter 1: **Bridged Adapter**
- Connected to: Your physical Ethernet adapter
- Purpose: Access to local network (QNAP NAS at 192.168.50.99)

**Configuration Steps**:
1. Shut down WIN11 VM
2. VirtualBox Manager → WIN11 VM → Settings → Network
3. Adapter 1:
   - Enable Network Adapter: ✓
   - Attached to: **Bridged Adapter**
   - Name: Select your physical Ethernet/Wi-Fi adapter
   - Adapter Type: Intel PRO/1000 MT Desktop (or default)
   - Promiscuous Mode: Deny
   - Cable Connected: ✓
4. Click OK
5. Start VM

**Verification** (run in VM):
```powershell
# Check IP address (should be on same subnet as 192.168.50.x)
ipconfig

# Test connectivity to QNAP NAS
Test-NetConnection -ComputerName 192.168.50.99 -Port 445

# Test ping
ping 192.168.50.99
```

---

## 📊 Test Data Requirements

### On QNAP NAS (192.168.50.99:/Public/Test)
- [ ] 1GB+ test folder for SMB copy tests
- [ ] Folder should contain multiple files (not single large file)

### On DIGI Storage (FTP Server)
- [ ] 100MB+ test file for download tests
- [ ] File should be accessible via FTP

---

## 🔄 Pre-Test Checklist (Run Before Each Configuration)

Before starting measurements for each configuration (Baseline, Symantec, OPNsense, Both), verify:

1. [ ] Z: drive is mapped and accessible: `Test-Path Z:\`
2. [ ] N: drive (QNAP) is mapped and accessible: `Test-Path N:\`
3. [ ] FTP connection to DIGI Storage works
4. [ ] BootRacer is installed and functional
5. [ ] All test scripts are on Z: drive
6. [ ] Windows is fully booted and idle (no updates running)
7. [ ] Network connectivity is stable (1Gbit LAN)

---

## 📁 Expected Directory Structure on Z: Drive (Host: C:\VMShare)

```
Z:\                                  (C:\VMShare on host)
├── scripts\
│   ├── smb-copy-test.ps1
│   ├── ftp-download-test.ps1
│   ├── process-count-test.ps1
│   └── ram-startup-test.ps1
├── data\
│   ├── baseline\
│   ├── symantec\
│   ├── opnsense\
│   └── both\
└── AV-Bench\
    ├── script.ps1
    └── measurements.csv
```

---

## 🚀 Quick Setup Script (Run as Administrator in VM)

```powershell
# Quick setup verification script
Write-Host "=== WIN11 VM Setup Verification ===" -ForegroundColor Cyan

# 1. Check Z: drive mapping
if (Test-Path Z:\) {
    Write-Host "[OK] Z: drive is mapped" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Z: drive is NOT mapped" -ForegroundColor Red
    Write-Host "Run: net use Z: \\VBOXSVR\VMShare /persistent:yes" -ForegroundColor Yellow
}

# 2. Check N: drive mapping (QNAP)
if (Test-Path N:\) {
    Write-Host "[OK] N: drive (QNAP) is mapped" -ForegroundColor Green
} else {
    Write-Host "[FAIL] N: drive is NOT mapped" -ForegroundColor Red
    Write-Host "Run: net use N: \\192.168.50.99\Public\Test /persistent:yes" -ForegroundColor Yellow
}

# 3. Check network connectivity to QNAP
$qnapTest = Test-NetConnection -ComputerName 192.168.50.99 -Port 445 -WarningAction SilentlyContinue
if ($qnapTest.TcpTestSucceeded) {
    Write-Host "[OK] QNAP NAS is reachable (SMB port 445)" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Cannot reach QNAP NAS" -ForegroundColor Red
}

# 4. Check BootRacer installation
$bootRacerPath = "C:\Program Files\BootRacer\BootRacer.exe"
if (Test-Path $bootRacerPath) {
    Write-Host "[OK] BootRacer is installed" -ForegroundColor Green
} else {
    Write-Host "[WARN] BootRacer not found at expected path" -ForegroundColor Yellow
}

# 5. Check process counting capability
try {
    $processCount = (Get-Process | Measure-Object).Count
    Write-Host "[OK] Can count processes: $processCount running" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Cannot count processes" -ForegroundColor Red
}

# 6. Check RAM measurement capability
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $usedRAM = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)/1KB,2)
    Write-Host "[OK] Can measure RAM: ${usedRAM}MB used" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Cannot measure RAM" -ForegroundColor Red
}

Write-Host "`n=== Setup Verification Complete ===" -ForegroundColor Cyan
```

Save this as `Z:\setup-check.ps1` and run it before starting tests.

---

## 🔧 Troubleshooting

### Issue: Z: drive not mapping
**Solution**:
```powershell
# Remove existing mapping
net use Z: /delete
# Remap
net use Z: \\VBOXSVR\VMShare /persistent:yes
```

### Issue: Cannot access QNAP NAS
**Solution**:
1. Verify network adapter is in Bridged mode
2. Check VM has valid IP on same subnet: `ipconfig`
3. Test ping: `ping 192.168.50.99`
4. Check Windows Firewall isn't blocking SMB
5. Verify QNAP share permissions

### Issue: FTP connection fails
**Solution**:
1. Verify FTP credentials
2. Check firewall rules (port 21)
3. Test from command line: `ftp digi-storage-server`
4. Consider using passive mode if behind NAT

---

**Setup Status**: ⏳ Pending  
**Next Step**: Run setup verification script and configure missing items
