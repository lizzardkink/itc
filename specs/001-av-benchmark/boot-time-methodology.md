# Boot Time Measurement Methodology

## Overview
Boot time is measured using BootRacer, which tracks the COMPLETE boot sequence from power-on to fully usable desktop.

## BootRacer Metrics

BootRacer measures three distinct phases:

1. **Time to Logon**: Seconds from boot start until the Windows logon screen appears
2. **Logon Timeout**: Seconds spent at the logon screen (if applicable)
3. **Logon to Desktop**: Seconds from logon until desktop is fully ready and usable

**TOTAL BOOT TIME = Time to Logon + Logon Timeout + Logon to Desktop**

## Data Storage Locations

### On the VM (WIN11):
- **Primary History File**: `C:\Users\Public\Documents\Bootracer.his` (binary format, 65KB circular buffer) **← PRIMARY DATA SOURCE**
- **Exported CSV**: `C:\Users\admin\Desktop\BootRacer_history.CSV` (optional export from GUI, NOT used for automated collection)
- **Registry Entry**: `HKLM:\Software\WOW6432Node\Greatis\BootRacer` (contains most recent boot only - INCOMPLETE DATA)

### Data Collection Source:
**The .his file is the authoritative source** - it contains the complete boot history with all components. The CSV is only for manual verification.

### CSV Format:
```
Boot Finish Date/Time, BIOS Time, Time to Logon, Logon Timeout, Logon to Desktop, Grade, Change, Boot Result, ...
1/16/2026 23:19:42, "", 17, 0, 51, "", -8.297, 68.156, "", "", "", ""
```

## Data Collection Method

### Automated Method (CORRECT):

```powershell
# Read the .his file directly from VM
$hisPath = "C:\Users\Public\Documents\Bootracer.his"
$content = Get-Content $hisPath

# Parse most recent boot entry
$bootTimes = @()
$currentBoot = @{}

foreach ($line in $content) {
    if ($line -match "BootStart=(\d+)") {
        $currentBoot.BootStart = $matches[1]
    }
    elseif ($line -match "TimeLogonScreen=(\d+)") {
        $currentBoot.TimeToLogon = [int]$matches[1]
    }
    elseif ($line -match "TimeDesktopReady=(\d+)") {
        $currentBoot.TimeDesktopReady = [int]$matches[1]
    }
    elseif ($line -match "UserName=(.+)") {
        # Calculate TOTAL boot time
        $totalBootTime = $currentBoot.TimeToLogon + $currentBoot.TimeDesktopReady
        # Save boot record
        $bootTimes += [PSCustomObject]@{
            BootStart = $currentBoot.BootStart
            TimeToLogon = $currentBoot.TimeToLogon
            TimeDesktopReady = $currentBoot.TimeDesktopReady
            TotalBootTime = $totalBootTime
        }
        $currentBoot = @{}
    }
}

# Get most recent boot
$latestBoot = $bootTimes | Select-Object -Last 1
```

### Manual Method (For Verification Only):
1. Open BootRacer on the VM
2. Click "Export" → Save to Desktop as `BootRacer_history.CSV`
3. Manually verify values match .his file data

## Measurement Protocol

### Prerequisites:
- BootRacer installed and configured on VM
- Automatic boot time recording enabled (BootRacer runs on startup)
- CSV export available on VM desktop

### Per-Boot Recording:
1. VM boots from snapshot
2. BootRacer automatically records boot metrics to `.his` file
3. After stabilization period (30s), export BootRacer history to CSV via GUI or script
4. Copy CSV to shared folder for analysis
5. Parse CSV to extract TOTAL boot time for this iteration

### Data Validation:
- Verify all three components are recorded (Time to Logon, Logon Timeout, Logon to Desktop)
- Confirm TOTAL boot time is within expected range (60-100s for baseline, may vary with IDS)
- Flag any boot with excessive Logon Timeout (>30s) as anomalous

## Boot Time Clusters

Boot times are grouped by configuration and test date:

**Example from current data:**
- **Cluster 1** (Jan 6, 2026): 5 boots, avg ~89s, range 61-155s
- **Cluster 2** (Jan 16, 2026): 11 boots, avg ~77s, range 62-91s

Each configuration (Baseline, Symantec, Firewall, Both) will have its own cluster.

## Reporting Format

### Raw Data CSV:
```
Iteration,Timestamp,TimeToLogon,LogonTimeout,LogonToDesktop,TotalBootTime,Configuration
1,2026-01-16 13:34:29,25,0,59,84,baseline
2,2026-01-16 13:36:47,21,0,49,70,baseline
```

### Summary Statistics:
```
Configuration: Baseline (No IDS)
  Average Total Boot Time: 77.5 seconds
  Minimum: 62 seconds
  Maximum: 91 seconds
  Standard Deviation: 8.2 seconds
  Iterations: 5
```

## Criterion (e) - Boot Time

**Requirement**: Measure boot time for all 4 configurations

**Metric**: Total boot time from power-on to fully usable desktop (seconds)

**Measurement Tool**: BootRacer (https://www.greatis.com/bootracer/)

**Data Source**: `BootRacer_history.CSV` exported from VM

**Baseline Target**: 60-90 seconds (no IDS)

**Expected Overhead**: 
- AV only: +5-15%
- Firewall only: +3-10%
- AV + Firewall: +10-25%

**Iterations per Configuration**: Minimum 5 (to establish statistical validity)

## Files and Scripts

### Data Collection Script:
- `scripts/Automated-Boot-Cycle-With-BootRacer.ps1` - Automated boot cycling and measurement

### Data Analysis Script:
- `scripts/Get-TotalBootTimes.ps1` - Parse BootRacer CSV and calculate totals

### Helper Scripts (in VMShare):
- `Get-TotalBootTimes.ps1` - Calculate TOTAL boot times from CSV
- `Parse-BootRacerHistory.ps1` - Parse binary .his file (backup method)

---

**Last Updated**: 2026-01-16
**Version**: 1.0
