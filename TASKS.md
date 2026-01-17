# ItC Project - Current Tasks

**Last Updated**: 2026-01-17T00:30 UTC

## ✅ Completed Tasks

### Infrastructure Setup
- [x] Set up VirtualBox VM (WIN11) with 8GB RAM
- [x] Configure shared folder (C:\VMShare ↔ Z:\)
- [x] Install BootRacer in VM for boot time measurement
- [x] Configure VBoxManage guest control for remote execution
- [x] Set up NAS access (\\192.168.1.126\Public\test)
- [x] Set up FTP access (ftp://192.168.1.125)

### Script Development
- [x] Create boot cycle test script with BootRacer integration
- [x] Create app launch test script (75 apps, randomized)
- [x] Create SMB copy test script
- [x] Create FTP download test script
- [x] Create individual pipeline scripts for each config
- [x] Create master batch file for all configs
- [x] Create quick test script (1 iteration) for debugging
- [x] Add progress bars to all pipeline scripts
- [x] Add status displays to all pipeline scripts
- [x] Add timestamps to all CSV outputs

### Data Structure
- [x] Create 4 configuration folders (baseline, antivirus, firewall, both)
- [x] Create 24 CSV files (6 per configuration)
- [x] Remove old/test folders (test, opnsense, symantec)
- [x] Align all scripts with 4-folder structure
- [x] Verify dynamic ConfigName parameter in all scripts

### VM Helper Scripts
- [x] Create VM-Helper-App-Launch.ps1 (with randomization)
- [x] Create VM-Helper-SMB-Copy.ps1
- [x] Create VM-Helper-FTP-Download.ps1
- [x] Create Get-LatestBootTime.ps1 (reads BootRacer .his file)
- [x] Create Get-MemoryInfo.ps1
- [x] Create Get-StartupInfo.ps1

### Testing & Validation
- [x] Test boot cycle with VM reboot
- [x] Test app launcher with randomization
- [x] Test SMB copy performance
- [x] Test FTP download performance
- [x] Test quick pipeline (1 iteration)
- [x] Verify CSV recording paths
- [x] Audit all scripts for folder alignment

### Documentation
- [x] Create README.md with project overview
- [x] Create TASKS.md with current status
- [x] Document data structure
- [x] Document test criteria
- [x] Document running instructions

---

## 🚀 Ready to Execute

### Next Steps: Data Collection

1. **Run Baseline Configuration** (~25 minutes)
   ```powershell
   .\scripts\Run-Baseline-Full-Pipeline.ps1
   ```
   - 5 boot cycles
   - 5 app launch tests
   - 5 SMB copy tests
   - 5 FTP download tests

2. **Prepare VM for Antivirus Configuration**
   - Install Symantec Endpoint Protection
   - Verify it's running
   - Ensure it doesn't interfere with test scripts

3. **Run Antivirus Configuration** (~25 minutes)
   ```powershell
   .\scripts\Run-Antivirus-Full-Pipeline.ps1
   ```

4. **Prepare VM for Firewall Configuration**
   - Uninstall Symantec Endpoint Protection
   - Enable Windows Firewall (all profiles)
   - Verify firewall is active

5. **Run Firewall Configuration** (~25 minutes)
   ```powershell
   .\scripts\Run-Firewall-Full-Pipeline.ps1
   ```

6. **Prepare VM for Both Configuration**
   - Re-install Symantec Endpoint Protection
   - Keep Windows Firewall enabled
   - Verify both are active

7. **Run Both Configuration** (~25 minutes)
   ```powershell
   .\scripts\Run-Both-Full-Pipeline.ps1
   ```

### Alternative: Run All at Once

```cmd
.\scripts\Run-All-Configurations.bat
```

This will prompt you between each configuration for manual VM setup.

**Total time: ~100 minutes**

---

## 📊 Data Analysis (After Collection)

### Pending Tasks

- [ ] **Statistical Analysis**
  - [ ] Calculate mean, median, std dev for each metric
  - [ ] Compare baseline vs antivirus
  - [ ] Compare baseline vs firewall
  - [ ] Compare baseline vs both
  - [ ] Identify statistical significance

- [ ] **Visualization**
  - [ ] Create boot time comparison charts
  - [ ] Create RAM usage comparison charts
  - [ ] Create process count comparison charts
  - [ ] Create app launch time comparison charts
  - [ ] Create network performance comparison charts
  - [ ] Create summary dashboard

- [ ] **Reporting**
  - [ ] Write findings report
  - [ ] Document performance impact percentages
  - [ ] Create executive summary
  - [ ] Format for academic paper (if applicable)

---

## 🔍 Investigation Items

### Open Questions

- [ ] **PowerShell Window at Startup**
  - Is it appearing at VM boot or only during test execution?
  - If at boot, identify the trigger
  - If during tests, it's normal (VBoxManage creates it)

### Optimization Opportunities

- [ ] Consider running tests in parallel (if resources allow)
- [ ] Add error recovery/retry logic to scripts
- [ ] Add email/notification when long tests complete
- [ ] Create analysis automation scripts

---

## 📁 File Inventory

### Scripts Directory (Host)
- Automated-Boot-Cycle-With-BootRacer.ps1
- Test-AppLaunch-Remote.ps1
- SMB-Copy-Test.ps1
- FTP-Download-Test.ps1
- Run-Baseline-Full-Pipeline.ps1
- Run-Antivirus-Full-Pipeline.ps1
- Run-Firewall-Full-Pipeline.ps1
- Run-Both-Full-Pipeline.ps1
- Run-All-Configurations.bat
- Test-Pipeline-Quick.ps1
- Invoke-VMCommand.ps1 (helper)

### VMShare Directory (VM-accessible)
- VM-Helper-App-Launch.ps1
- VM-Helper-SMB-Copy.ps1
- VM-Helper-FTP-Download.ps1
- Get-LatestBootTime.ps1
- Get-MemoryInfo.ps1
- Get-StartupInfo.ps1
- Find-PowerShellStartup.ps1

### Data Directory
- baseline/ (6 CSV files - ready)
- antivirus/ (6 CSV files - ready)
- firewall/ (6 CSV files - ready)
- both/ (6 CSV files - ready)

---

## 🎯 Success Criteria

**Project is complete when:**

1. ✅ All 4 configurations have been tested (5 iterations each)
2. ✅ All 24 CSV files contain 5 data rows each (120 total measurements)
3. ✅ Statistical analysis completed comparing all configurations
4. ✅ Visualizations created for all 6 criteria
5. ✅ Final report documenting findings and performance impact

**Current Status: Ready for Data Collection** 🚀
