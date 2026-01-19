# Hardware Specifications: IDS Benchmark Study

**Document Purpose**: Complete hardware specifications for academic paper methodology section  
**Last Updated**: 2026-01-19  
**Project**: 001-av-benchmark

---

## Host System Specifications

### Computer Platform
- **Manufacturer**: Lenovo ThinkPad
- **Model**: 20XXS1MM00
- **Operating System**: Microsoft Windows 11 Pro (Version 10.0.22631)

### Processor (CPU)
- **Model**: Intel Core i7-1185G7 (11th Generation)
- **Base Frequency**: 3.00 GHz
- **Max Turbo Frequency**: 2995 MHz (measured)
- **Architecture**: Tiger Lake (10nm)
- **Physical Cores**: 4
- **Logical Processors**: 8 (Hyper-Threading enabled)
- **Cache**: 12 MB Intel Smart Cache
- **TDP**: 28W (configurable up to 35W)

### Memory (RAM)
- **Total Capacity**: 16 GB (16868499456 bytes)
- **Configuration**: 8 × 2 GB modules
- **Manufacturer**: Samsung
- **Part Number**: UBE3D4AA-MGCR
- **Type**: DDR4 SDRAM
- **Speed**: 4267 MHz
- **Configured Clock Speed**: 4267 MHz
- **Voltage**: 0.6V (600mV - Low Power DDR4)
- **Form Factor**: SO-DIMM (laptop memory)

### Storage
- **Drive Model**: Kingston SNV3S1000G
- **Type**: NVMe SSD (Solid State Drive)
- **Interface**: PCIe NVMe (Non-Volatile Memory Express)
- **Capacity**: 1 TB (1000204886016 bytes ≈ 931.51 GB usable)
- **Bus Type**: NVMe

---

## Virtual Machine Specifications (WIN11)

### Virtualization Platform
- **Hypervisor**: Oracle VM VirtualBox
- **Version**: 7.2.2 r170484
- **Guest Additions**: 7.2.2 r170484 (installed)
- **VM Name**: WIN11
- **VM UUID**: a5339315-24b3-4095-9807-0ab5ca680101
- **Guest OS Type**: Windows 11 (64-bit)

### Allocated Resources

#### Virtual CPU
- **Virtual CPU Count**: 4 cores
- **CPU Execution Cap**: 100%
- **Hardware Virtualization**: Intel VT-x enabled
- **Large Pages**: Enabled
- **PAE/NX**: Enabled
- **Host CPU Passthrough**: Partial (4 of 8 logical processors)

#### Virtual Memory
- **Allocated RAM**: 8 GB (8192 MB)
- **Video Memory (VRAM)**: 128 MB
- **Memory Balloon**: Dynamic (VirtualBox Guest Additions)
- **Page Fusion**: Disabled

#### Virtual Display
- **Graphics Controller**: VBoxSVGA
- **Video Memory**: 128 MB
- **Monitor Count**: 1
- **3D Acceleration**: Disabled
- **2D Video Acceleration**: Enabled

#### Virtual Storage
- **Controller Type**: SATA (AHCI)
- **Virtual Disk Format**: VDI (VirtualBox Disk Image)
- **Disk Type**: Dynamically allocated
- **Host Cache**: I/O APIC enabled

#### Network Configuration
- **Adapter 1**: Bridged Adapter
- **Adapter Type**: Intel PRO/1000 MT Desktop (82540EM)
- **Connection**: Connected to host physical network
- **MAC Address**: Auto-generated
- **Bandwidth**: 1 Gbps (limited by host network)

#### Shared Folders
- **Share Name**: VMShare
- **Host Path**: C:\VMShare
- **Guest Mount Point**: Z: drive (automatic)
- **Access**: Read-only from guest
- **Auto-mount**: Enabled
- **Purpose**: Data collection and test result storage

---

## Network Infrastructure

### Local Area Network (LAN)
- **Network Speed**: 1 Gigabit Ethernet (1000 Mbps)
- **Protocol for Testing**: SMB (Server Message Block)
- **NAS Device**: QNAP Network Attached Storage
- **NAS IP Address**: 192.168.50.99
- **Test Share Path**: \\192.168.50.99\Public\Test
- **Test Data Size**: 1 GB folder (recursive copy)

### Remote Storage (FTP)
- **Service**: DIGI Storage
- **Protocol**: FTP (File Transfer Protocol)
- **Client Software**: FileZilla
- **Test File Size**: 100 MB
- **Connection Type**: Standard FTP

---

## Software Environment

### Guest Operating System
- **OS**: Windows 11 Professional (64-bit)
- **Version**: To be documented from VM
- **Updates**: Current as of snapshot date
- **Windows Defender**: Disabled for baseline configuration

### Testing Tools (Pre-installed in VM)
- **Boot Time Measurement**: BootRacer (version to be documented)
- **Performance Monitoring**: Windows Performance Monitor (built-in)
- **Application Launch Testing**: AV-Bench/script.ps1 (custom PowerShell script)
- **Remote Access**: WinRM (Windows Remote Management) - if enabled

### Intrusion Detection Software Under Test
1. **Antivirus**: TotalAV version 6.5.219
2. **Firewall**: Fort Firewall version 3.19.9

---

## Snapshot Configuration

### Baseline Snapshot
- **Name**: "Clean" (to be renamed "Baseline-NoIDS")
- **Created**: 2026-01-16 15:48:20 UTC
- **Status**: Clean Windows 11 with no IDS installed
- **Guest Additions**: Installed and operational

### Test Configuration Snapshots (To Be Created)
1. **Baseline-NoIDS**: Clean system, no antivirus or firewall
2. **TotalAV-Only**: TotalAV 6.5.219 installed and active
3. **FortFirewall-Only**: Fort Firewall 3.19.9 installed and active
4. **TotalAV-FortFirewall-Both**: Both IDS components active

---

## Methodology Notes for Academic Paper

### Hardware Configuration Rationale
- **CPU Allocation**: 4 virtual cores provide adequate processing power for Windows 11 while representing typical desktop workstation configuration
- **RAM Allocation**: 8 GB meets Windows 11 recommended specifications and supports both operating system and IDS software
- **Storage**: NVMe SSD on host ensures fast I/O performance, minimizing storage bottleneck in measurements
- **Network**: Bridged adapter provides direct network access comparable to physical installation

### Consistency Measures
- All tests performed on identical VM snapshots
- Host system maintained in consistent state (no other VMs running during tests)
- Network conditions monitored for consistency
- 5 iterations per test to establish statistical validity
- Snapshot restore ensures identical starting conditions for each configuration

### Known Limitations
- Virtualization introduces performance overhead compared to bare-metal installation
- Shared folder performance may differ from native guest filesystem
- Network performance limited by host network adapter capabilities
- Test results specific to this hardware configuration

---

## Citations for Methodology Section

**Host System**:
- CPU: Intel Core i7-1185G7 (Tiger Lake, 11th Gen, 4C/8T @ 3.0-4.8 GHz)
- RAM: 16 GB DDR4-4267 (Samsung dual-channel configuration)
- Storage: 1 TB Kingston SNV3S1000G NVMe SSD

**Virtual Machine**:
- Platform: Oracle VirtualBox 7.2.2
- Guest: Windows 11 Pro 64-bit
- Resources: 4 vCPUs, 8 GB RAM, 128 MB VRAM
- Network: Bridged adapter (1 Gbps LAN)

**Test Environment**:
- IDS Software: TotalAV 6.5.219, Fort Firewall 3.19.9
- Network: 1 Gbps LAN (QNAP NAS), FTP (DIGI Storage)
- Tools: BootRacer, Windows Performance Monitor, AV-Bench script
