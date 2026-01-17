# Analyze-AllData.ps1
# Analyzes all test data from 4 configurations and generates paper.md
# Created: 2026-01-16

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   DATA ANALYSIS & PAPER GENERATION" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$dataRoot = "C:\VMShare\data"
$configs = @("baseline", "symantec", "firewall", "both")
$criteria = @{
    "boot-time" = "Boot Time (s)"
    "ram-startup" = "RAM Usage (MB)"
    "process-count" = "Process Count"
    "app-launch" = "App Launch Time (ms)"
    "smb-copy" = "SMB Transfer Speed (MB/s)"
    "ftp-download" = "FTP Download Speed (MB/s)"
}

# Verify data exists
Write-Host "Checking for data files..." -ForegroundColor Yellow
$missingData = @()

foreach ($config in $configs) {
    $configPath = Join-Path $dataRoot $config
    if (-not (Test-Path $configPath)) {
        $missingData += "Missing folder: $configPath"
        continue
    }
    
    foreach ($criterion in $criteria.Keys) {
        $csvFile = Join-Path $configPath "$criterion-$config.csv"
        if (-not (Test-Path $csvFile)) {
            $missingData += "Missing: $csvFile"
        }
    }
}

if ($missingData.Count -gt 0) {
    Write-Host ""
    Write-Host "WARNING: Missing data files:" -ForegroundColor Red
    $missingData | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    Write-Host ""
    $continue = Read-Host "Continue anyway? (Y/N)"
    if ($continue -ne "Y" -and $continue -ne "y") {
        exit
    }
}

Write-Host "✓ Data verification complete" -ForegroundColor Green
Write-Host ""

# Analyze each criterion
$analysis = @{}

foreach ($criterion in $criteria.Keys) {
    Write-Host "Analyzing $criterion..." -ForegroundColor Cyan
    
    $analysis[$criterion] = @{}
    
    foreach ($config in $configs) {
        $csvFile = Join-Path $dataRoot "$config\$criterion-$config.csv"
        
        if (Test-Path $csvFile) {
            $data = Import-Csv $csvFile
            
            # Extract numerical values based on criterion type
            $values = switch ($criterion) {
                "boot-time" { $data | ForEach-Object { [double]$_.BootTimeSeconds } }
                "ram-startup" { $data | ForEach-Object { [double]$_.UsedMB } }
                "process-count" { $data | ForEach-Object { [int]$_.ProcessCount } }
                "app-launch" { 
                    # App launch has different format - milliseconds in column 3
                    $data | ForEach-Object { 
                        if ($_.PSObject.Properties.Name -contains "3") {
                            [double]$_."3"
                        } elseif ($_.PSObject.Properties.Count -ge 3) {
                            [double]($_.PSObject.Properties.Value)[2]
                        }
                    }
                }
                "smb-copy" { $data | ForEach-Object { [double]$_.SpeedMBps } }
                "ftp-download" { $data | ForEach-Object { [double]$_.SpeedMBps } }
            }
            
            if ($values) {
                $avg = ($values | Measure-Object -Average).Average
                $min = ($values | Measure-Object -Minimum).Minimum
                $max = ($values | Measure-Object -Maximum).Maximum
                $count = $values.Count
                
                # Calculate standard deviation
                $variance = ($values | ForEach-Object { [Math]::Pow($_ - $avg, 2) } | Measure-Object -Average).Average
                $stdDev = [Math]::Sqrt($variance)
                
                $analysis[$criterion][$config] = @{
                    Average = [Math]::Round($avg, 2)
                    Min = [Math]::Round($min, 2)
                    Max = [Math]::Round($max, 2)
                    StdDev = [Math]::Round($stdDev, 2)
                    Count = $count
                }
            }
        }
    }
}

# Calculate overhead percentages
Write-Host ""
Write-Host "Calculating overhead percentages..." -ForegroundColor Cyan

$overhead = @{}
foreach ($criterion in $criteria.Keys) {
    if ($analysis[$criterion].ContainsKey("baseline")) {
        $baseline = $analysis[$criterion]["baseline"].Average
        $overhead[$criterion] = @{}
        
        foreach ($config in @("symantec", "firewall", "both")) {
            if ($analysis[$criterion].ContainsKey($config)) {
                $configValue = $analysis[$criterion][$config].Average
                
                # For speed tests (SMB, FTP), negative overhead is worse performance
                # For time/resource tests, positive overhead is worse
                if ($criterion -in @("smb-copy", "ftp-download")) {
                    $overheadPercent = (($baseline - $configValue) / $baseline) * 100
                } else {
                    $overheadPercent = (($configValue - $baseline) / $baseline) * 100
                }
                
                $overhead[$criterion][$config] = [Math]::Round($overheadPercent, 2)
            }
        }
    }
}

# Generate paper.md
Write-Host ""
Write-Host "Generating paper.md..." -ForegroundColor Cyan

$paperContent = @"
# IDS Impact Analysis Research Paper
**Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm")  
**Status**: DRAFT - Awaiting Review

---

## Abstract

This study analyzes the performance impact of Intrusion Detection Systems (IDS) on Windows 11 computational resources. Four configurations were tested: baseline (no IDS), Symantec Endpoint Protection only, firewall only, and both combined. Six performance criteria were measured across five iterations each: boot time, RAM usage, process count, application launch performance, SMB network transfer speed, and FTP download speed.

---

## 1. Introduction

Intrusion Detection Systems (IDS) are essential security components that monitor and analyze system activities to detect potential security breaches. However, these systems can impact system performance. This research quantifies the performance overhead of Symantec Endpoint Protection and firewall implementations on a Windows 11 system.

### Research Objectives
- Measure baseline system performance without IDS
- Quantify performance impact of Symantec Endpoint Protection
- Quantify performance impact of firewall configuration  
- Analyze combined impact when both IDS components are active
- Compare performance overhead across six different criteria

---

## 2. Methodology

### 2.1 Test Environment

**Hardware Configuration:**
- Platform: Oracle VirtualBox VM
- Processor: Intel Core i7-1185G7 @ 3.0GHz (4 cores, 4 logical processors)
- Memory: 8 GB RAM
- Storage: 59 GB virtual disk
- Network: 1 Gbps Ethernet (NAT)

**Software Configuration:**
- Operating System: Microsoft Windows 11 Home (Build 26200, 64-bit)
- PowerShell: Version 5.1.26100.7462
- Antivirus: Symantec Endpoint Protection
- Firewall: [Specify: OPNsense or Windows Firewall]

**Network Configuration:**
- SMB Testing: QNAP NAS at 192.168.50.99 via 1 Gbps LAN
- FTP Testing: DIGI Storage (storage.rcs-rds.ro)
- Data Collection: Shared folder (Host C:\VMShare mapped to Guest Z:)

### 2.2 Test Configurations

Four configurations were tested:

1. **Baseline**: Clean Windows 11 with no IDS components
2. **Symantec Only**: Symantec Endpoint Protection with real-time protection enabled
3. **Firewall Only**: Firewall with active rules and logging
4. **Combined (Both)**: Both Symantec and firewall active simultaneously

### 2.3 Performance Criteria

Six criteria were measured, each with 5 iterations for statistical validity:

**Criterion A - Boot Time**
- Tool: BootRacer  
- Measurement: Time from power-on to desktop ready (seconds)
- Iterations: 5 (5 reboots per configuration)

**Criterion B - RAM Usage at Startup**
- Tool: PowerShell (Win32_OperatingSystem)
- Measurement: Memory consumed 30 seconds after boot (MB)
- Iterations: 5

**Criterion C - Process Count at Startup**
- Tool: PowerShell (Get-Process)
- Measurement: Number of running processes 30 seconds after boot
- Iterations: 5

**Criterion D - Application Launch Performance**
- Tool: Custom PowerShell script (AV-Bench based)
- Measurement: Time to launch 75 applications (25 Calculator, 25 Paint, 25 Notepad)
- Iterations: 5 (375 total application launches per configuration)

**Criterion E - SMB Network Transfer**
- Tool: PowerShell file copy
- Source: QNAP NAS test folder (\\192.168.50.99\Public\Test)
- Destination: VM Desktop\SMB folder
- Measurement: Transfer speed (MB/s) for [SIZE] GB over SMB
- Iterations: 5

**Criterion F - FTP Remote Download**
- Tool: PowerShell FTP client
- Source: DIGI Storage FTP (storage.rcs-rds.ro/Digi Cloud/Test)
- Destination: VM Desktop\FTP folder  
- File: 202.09 MB test file
- Measurement: Download speed (MB/s)
- Iterations: 5

### 2.4 Testing Procedure

1. Restore appropriate VM snapshot
2. Ensure consistent starting state (auto-login configured, services stable)
3. Execute automated test scripts via PowerShell remoting
4. Save results to CSV files in shared folder
5. Clean up test files between iterations
6. Repeat for all 4 configurations

### 2.5 Data Collection

All measurements were automatically saved to CSV files:
- Boot time: boot-time-{config}.csv
- RAM usage: ram-startup-{config}.csv
- Process count: process-count-{config}.csv  
- App launch: app-launch-{config}.csv
- SMB transfer: smb-copy-{config}.csv
- FTP download: ftp-download-{config}.csv

---

## 3. Results

### 3.1 Summary Statistics

"@

# Add summary table
$paperContent += "`n#### Table 1: Performance Measurements Across All Configurations`n`n"
$paperContent += "| Criterion | Baseline | Symantec | Firewall | Both |`n"
$paperContent += "|-----------|----------|----------|----------|------|`n"

foreach ($criterion in $criteria.Keys) {
    $label = $criteria[$criterion]
    $row = "| $label | "
    
    foreach ($config in $configs) {
        if ($analysis[$criterion].ContainsKey($config)) {
            $avg = $analysis[$criterion][$config].Average
            $stdDev = $analysis[$criterion][$config].StdDev
            $row += "$avg ± $stdDev | "
        } else {
            $row += "N/A | "
        }
    }
    
    $paperContent += "$row`n"
}

# Add overhead table
$paperContent += "`n#### Table 2: Performance Overhead vs Baseline (%)`n`n"
$paperContent += "| Criterion | Symantec | Firewall | Both |`n"
$paperContent += "|-----------|----------|----------|------|`n"

foreach ($criterion in $criteria.Keys) {
    $label = $criteria[$criterion]
    $row = "| $label | "
    
    foreach ($config in @("symantec", "firewall", "both")) {
        if ($overhead[$criterion].ContainsKey($config)) {
            $oh = $overhead[$criterion][$config]
            $row += "$oh% | "
        } else {
            $row += "N/A | "
        }
    }
    
    $paperContent += "$row`n"
}

$paperContent += @"

### 3.2 Detailed Analysis by Criterion

[Detailed analysis of each criterion will be added here based on the data]

---

## 4. Discussion

### 4.1 Performance Impact Patterns

[Analysis of which configurations had the most impact]

### 4.2 Symantec Endpoint Protection Impact

[Specific analysis of Symantec overhead]

### 4.3 Firewall Impact

[Specific analysis of firewall overhead]

### 4.4 Combined Impact

[Analysis of whether combined overhead is additive or has synergies]

### 4.5 Limitations

- Testing performed in virtualized environment
- Single hardware configuration
- Limited to Windows 11 Home
- Network tests dependent on external infrastructure

---

## 5. Conclusion

This research quantified the performance overhead of IDS components on Windows 11 systems. 

[Key findings to be summarized after review]

### Future Work

- Test on physical hardware
- Test with different AV/firewall products
- Long-term performance monitoring
- Real-world workload scenarios

---

## 6. References

[To be added]

---

**END OF DRAFT**

---

## Appendix A: Raw Data Files

All raw measurement data is available in CSV format:
- Location: C:\VMShare\data\{configuration}\
- 24 total CSV files (4 configurations × 6 criteria)

## Appendix B: Test Scripts

All automated test scripts available at:
- C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\scripts\

"@

# Save paper.md
$paperPath = "C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\paper.md"
$paperContent | Out-File -FilePath $paperPath -Encoding UTF8

Write-Host "✓ paper.md generated at: $paperPath" -ForegroundColor Green

# Display summary
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   ANALYSIS COMPLETE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "Summary Statistics:" -ForegroundColor Yellow
foreach ($criterion in $criteria.Keys) {
    Write-Host ""
    Write-Host "  $($criteria[$criterion]):" -ForegroundColor Cyan
    foreach ($config in $configs) {
        if ($analysis[$criterion].ContainsKey($config)) {
            $avg = $analysis[$criterion][$config].Average
            $std = $analysis[$criterion][$config].StdDev
            $oh = if ($overhead[$criterion].ContainsKey($config)) { " ($($overhead[$criterion][$config])% overhead)" } else { "" }
            Write-Host "    $config`: $avg ± $std$oh" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review paper.md at: $paperPath" -ForegroundColor Gray
Write-Host "  2. Add detailed analysis and discussion" -ForegroundColor Gray
Write-Host "  3. After approval, convert to LaTeX" -ForegroundColor Gray
Write-Host "  4. Generate graphs for paper" -ForegroundColor Gray
Write-Host ""
