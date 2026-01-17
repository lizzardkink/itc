# VM Environment Setup Checklist
**Date**: 2026-01-16  
**VM Name**: WIN11  
**Purpose**: IDS Performance Impact Testing  
**Phase**: Phase 0 - Environment Setup

---

## ✅ TASK-001: Rename VM Snapshot (5 minutes)

**Current**: Snapshot named "Clean"  
**Target**: Rename to "Baseline-NoIDS"

### Steps:
1. Open **VirtualBox Manager**
2. Select **WIN11** VM from the list
3. Click on **Snapshots** tab (right side panel)
4. Right-click on **"Clean"** snapshot
5. Select **"Rename Snapshot..."**
6. Enter new name: `Baseline-NoIDS`
7. Update description:
   ```
   Windows 11 clean baseline configuration
   - OS fully updated (as of snapshot date)
   - No antivirus software installed
   - No third-party firewall installed
   - Windows Defender active (default state)
   - No network configuration changes
   - Ready for IDS testing baseline measurements
   ```
8. Click **OK**

### Verification:
- [ ] Snapshot renamed to "Baseline-NoIDS"
- [ ] Description updated
- [ ] Snapshot is restorable

---

## ✅ TASK-002: Configure VM Network to Bridged Mode (10 minutes)

**Current**: NAT mode (default VirtualBox)  
**Target**: Bridged Adapter for LAN access

### Why Bridged Mode?
- Direct access to QNAP NAS on local network
- Real network speeds (1Gbit) for SMB testing
- Acts like physical machine on LAN

### Steps:
1. Ensure WIN11 VM is **powered off** (not running)
2. In VirtualBox Manager, select **WIN11** VM
3. Click **Settings** (gear icon)
4. Navigate to **Network** section
5. Select **Adapter 1** tab
6. Change **"Attached to:"** from **NAT** → **Bridged Adapter**
7. In **"Name:"** dropdown, select your physical network adapter:
   - Usually: `Realtek PCIe GbE Family Controller` or similar
   - Should be the 1Gbit adapter connected to your LAN
8. Ensure **"Cable Connected"** is checked
9. Click **OK**

### Verification:
- [ ] Network mode changed to Bridged
- [ ] Physical adapter selected (1Gbit)
- [ ] Settings saved

### After Starting VM:
1. Boot WIN11 VM
2. Open Command Prompt in VM
3. Run: `ipconfig`
4. Verify VM has IP address on same subnet as host (e.g., 192.168.x.x)
5. Run: `ping 8.8.8.8` to verify internet connectivity
6. Run: `ping <QNAP_IP>` to verify NAS access

---

## ✅ TASK-003: Verify QNAP NAS Connectivity (15 minutes)

**Target**: Confirm SMB access to QNAP NAS for criterion (a) testing

### Prerequisites:
- QNAP NAS powered on
- NAS connected to same network (1Gbit LAN)
- Know NAS IP address or hostname

### Steps (from WIN11 VM):

1. **Find QNAP IP Address**:
   - Check QNAP LCD display, OR
   - Access QNAP Finder tool, OR
   - Check router DHCP leases

2. **Test Network Connectivity**:
   ```powershell
   # Replace <QNAP_IP> with actual IP, e.g., 192.168.1.100
   ping <QNAP_IP>
   ```

3. **Access QNAP via File Explorer**:
   - Open File Explorer in VM
   - In address bar, type: `\\<QNAP_IP>`
   - Press Enter
   - Enter QNAP credentials when prompted
   - You should see shared folders

4. **Alternative: Map Network Drive**:
   ```powershell
   # In PowerShell
   New-PSDrive -Name "Q" -PSProvider FileSystem -Root "\\<QNAP_IP>\<ShareName>" -Persist
   ```

5. **Test Write Access**:
   - Navigate to QNAP share
   - Create a test folder
   - Delete test folder

### Verification:
- [ ] Can ping QNAP NAS
- [ ] Can access QNAP shares via `\\<IP>`
- [ ] Can read files on QNAP
- [ ] Can write files to QNAP
- [ ] Document QNAP IP: ________________
- [ ] Document share name: ________________

---

## ✅ TASK-004: Create 1GB Test Folder on QNAP (10 minutes)

**Purpose**: Prepare test data for SMB copy speed testing (criterion a)

### Requirements:
- 1GB of mixed files (documents, images, etc.)
- Stored on QNAP NAS
- Accessible via SMB

### Option A: Create Test Files (Recommended)

**On QNAP** (via web interface or SSH):
```bash
# Create test directory
mkdir /share/TestData

# Generate 1GB test file (10 files of 100MB each for variety)
cd /share/TestData
for i in {1..10}; do
    dd if=/dev/urandom of=testfile_${i}.dat bs=1M count=100
done
```

**OR from Windows VM** (easier):
```powershell
# Map QNAP drive
$qnapPath = "\\<QNAP_IP>\<ShareName>"

# Create test folder
New-Item -Path "$qnapPath\IDS-TestData" -ItemType Directory

# Generate mixed test files
cd "$qnapPath\IDS-TestData"

# Create 100 x 10MB files for realistic file mix
1..100 | ForEach-Object {
    $size = 10MB
    $file = "testfile_$_.dat"
    fsutil file createnew $file $size
}
```

### Option B: Copy Real Data
- Copy existing folder from host to QNAP
- Must be ≥ 1GB total
- Should contain multiple files (not one huge file)

### Verification:
- [ ] Test folder exists on QNAP: `\\<QNAP_IP>\<ShareName>\IDS-TestData`
- [ ] Folder size ≥ 1GB
- [ ] Contains multiple files
- [ ] Accessible from WIN11 VM
- [ ] Document folder path: ________________

---

## ✅ TASK-005: Verify DIGI Storage FTP Access (15 minutes)

**Purpose**: Confirm FTP connectivity for remote download testing (criterion b)

### Prerequisites:
- DIGI Storage account credentials
- FTP enabled on DIGI Storage
- Internet connectivity from VM

### Steps (from WIN11 VM):

1. **Test FTP Connection via Browser**:
   - Open browser
   - Navigate to: `ftp://<DIGI_SERVER>`
   - Enter credentials when prompted
   - Verify you can browse files

2. **Test FTP via Command Line**:
   ```powershell
   # Test with Windows FTP client
   ftp
   > open <DIGI_SERVER_IP_OR_HOSTNAME>
   > <username>
   > <password>
   > dir
   > quit
   ```

3. **Test with PowerShell**:
   ```powershell
   # Modern method using WebClient
   $ftpUri = "ftp://<SERVER>/path/to/testfile.txt"
   $webclient = New-Object System.Net.WebClient
   $webclient.Credentials = New-Object System.Net.NetworkCredential("username", "password")
   $webclient.DownloadFile($ftpUri, "C:\temp\test.txt")
   ```

### Verification:
- [ ] Can connect to DIGI Storage FTP
- [ ] Credentials work
- [ ] Can list files
- [ ] Can download files
- [ ] Document FTP server: ________________
- [ ] Document FTP port (usually 21): ________________

---

## ✅ TASK-006: Upload 100MB Test File to DIGI Storage (10 minutes)

**Purpose**: Prepare test file for FTP download speed testing (criterion b)

### Requirements:
- File size ≥ 100MB
- Uploaded to DIGI Storage FTP
- Accessible via FTP download

### Steps:

1. **Generate 100MB Test File** (on host or in VM):
   ```powershell
   # Create 100MB file
   fsutil file createnew C:\temp\testfile_100mb.dat 104857600
   
   # Or create 150MB for safety margin
   fsutil file createnew C:\temp\testfile_150mb.dat 157286400
   ```

2. **Upload to DIGI Storage**:
   
   **Option A: Via FTP Client (FileZilla)**
   - Download FileZilla
   - Connect to DIGI Storage FTP
   - Upload testfile_100mb.dat
   
   **Option B: Via PowerShell**
   ```powershell
   $ftpServer = "ftp://<SERVER>/IDS-TestFile.dat"
   $localFile = "C:\temp\testfile_100mb.dat"
   $username = "your_username"
   $password = "your_password"
   
   $webclient = New-Object System.Net.WebClient
   $webclient.Credentials = New-Object System.Net.NetworkCredential($username, $password)
   $webclient.UploadFile($ftpServer, $localFile)
   ```

3. **Verify Upload**:
   ```powershell
   # List FTP directory to confirm file exists
   # Check file size matches (100MB+)
   ```

### Verification:
- [ ] 100MB+ file created
- [ ] File uploaded to DIGI Storage
- [ ] File accessible via FTP
- [ ] File size verified (≥ 100MB)
- [ ] Document FTP file path: ________________

---

## ✅ TASK-007: Install sysbench (30 minutes)

**Purpose**: Install sysbench for system benchmarking (criterion f)

### Background:
Sysbench is a cross-platform benchmark tool for:
- CPU performance
- Memory throughput
- File I/O operations

### Installation Options:

#### Option A: Via WSL (Windows Subsystem for Linux) - RECOMMENDED

1. **Enable WSL in Windows 11**:
   ```powershell
   # Run as Administrator in WIN11 VM
   wsl --install
   # Reboot VM if prompted
   ```

2. **Install Ubuntu in WSL**:
   ```powershell
   wsl --install -d Ubuntu
   # Create username/password when prompted
   ```

3. **Install sysbench in Ubuntu**:
   ```bash
   # In WSL Ubuntu terminal
   sudo apt update
   sudo apt install sysbench -y
   ```

4. **Verify Installation**:
   ```bash
   sysbench --version
   # Should show: sysbench 1.0.x
   ```

#### Option B: Build from Source (Advanced)

1. Download sysbench from: https://github.com/akopytov/sysbench
2. Follow Windows build instructions
3. Requires MinGW or Cygwin

#### Option C: Use Native Windows Alternative

- Use **CrystalDiskMark** for disk I/O
- Use **CPU-Z** benchmark for CPU
- Use **MemTest** for memory

### Verification:
- [ ] sysbench installed (WSL or native)
- [ ] Can run: `sysbench cpu run`
- [ ] Can run: `sysbench memory run`
- [ ] Can run: `sysbench fileio prepare`
- [ ] Installation method: ________________

---

## ✅ TASK-008: Install BootRacer (15 minutes)

**Purpose**: Install BootRacer for accurate boot time measurement (criterion e)

### Download BootRacer:
- **Website**: https://www.greatis.com/bootracer/
- **Version**: Free version is sufficient
- **Size**: ~5 MB

### Installation Steps (in WIN11 VM):

1. **Download Installer**:
   - Visit: https://www.greatis.com/bootracer/
   - Click "Download" for free version
   - Save to Downloads folder

2. **Install BootRacer**:
   - Run `bootracer-setup.exe`
   - Follow installation wizard
   - Accept default settings
   - Finish installation

3. **Configure BootRacer**:
   - Launch BootRacer
   - Go to Settings
   - Enable "Automatic measurement" (if available)
   - Set measurement to start after POST

4. **Test Measurement**:
   - Restart VM once
   - Check BootRacer shows boot time
   - Verify measurement includes:
     - BIOS time
     - Windows startup time
     - Desktop ready time

### Verification:
- [ ] BootRacer installed
- [ ] Application launches successfully
- [ ] Shows boot time after restart
- [ ] Can export data to CSV/text
- [ ] Document typical boot time: _______ seconds

---

## Summary Checklist

### VM Configuration:
- [ ] TASK-001: Snapshot renamed to "Baseline-NoIDS"
- [ ] TASK-002: Network configured to Bridged mode
- [ ] VM can access internet
- [ ] VM has LAN IP address (192.168.x.x)

### Network Storage:
- [ ] TASK-003: QNAP NAS accessible via SMB
- [ ] TASK-004: 1GB test folder created on QNAP
- [ ] TASK-005: DIGI Storage FTP accessible
- [ ] TASK-006: 100MB test file uploaded to DIGI

### Testing Tools:
- [ ] TASK-007: sysbench installed and working
- [ ] TASK-008: BootRacer installed and measuring
- [ ] AV-Bench script already modified (5 iterations)

### Documentation:
- [ ] QNAP IP address: ________________
- [ ] QNAP share name: ________________
- [ ] QNAP test folder path: ________________
- [ ] DIGI FTP server: ________________
- [ ] DIGI FTP test file path: ________________
- [ ] sysbench installation method: ________________

---

## Next Steps After Phase 0 Complete:

1. **Restore "Baseline-NoIDS" snapshot**
2. **Run Phase 1: Baseline Testing** (TASK-011 through TASK-017)
   - SMB copy test (5 iterations)
   - FTP download test (5 iterations)
   - Process count test (5 boots)
   - RAM startup test (5 boots)
   - Boot time test (5 boots)
   - sysbench tests (5 iterations)
   - App launch test (5 iterations)

3. **Proceed to Phase 2: Symantec Configuration**

---

**Estimated Time for Phase 0**: 2 hours  
**Status**: Ready to begin  
**Date Started**: 2026-01-16
