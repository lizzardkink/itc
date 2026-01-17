# Application Launch Performance Test

**Script**: `AV-Bench/script.ps1`  
**Purpose**: Measure system responsiveness by launching multiple application instances  
**Relevance**: Can be used as an additional performance criterion or validation test

## What This Script Does

The script measures how quickly the system can launch 75 application instances (25 each of Calculator, Paint, and Notepad) in randomized order, then logs the total time taken.

### Key Features:
- **Applications**: calc, mspaint, notepad
- **Instances**: 25 of each = 75 total processes per iteration
- **Iterations**: 5 runs (configured to match other tests)
- **Total Launches**: 375 application instances (75 per iteration × 5 iterations)
- **Output**: `measurements.csv` with timestamps and timing data
- **Cleanup**: Aggressive cleanup between iterations to ensure consistent state

## Script Breakdown

### Applications Tested
```powershell
$apps = @("calc", "mspaint", "notepad")
$instanceCount = 25  # 25 instances per app = 75 per iteration
$iterations = 5      # Run 5 times (matches other test consistency)
```

### Measurement Process
1. Randomize launch order (75 apps shuffled)
2. Start all applications sequentially
3. Measure total time from first to last launch
4. Record results with timestamp and index
5. Clean up all processes
6. Wait 5 seconds
7. Repeat for specified iterations

### Output Format
```csv
Index,Timestamp,TimeMs,TimeSeconds
1,2026-01-16 15:30:45,12543.67,12.544
2,2026-01-16 15:31:02,13201.23,13.201
3,2026-01-16 15:31:20,12899.45,12.899
4,2026-01-16 15:31:38,12756.89,12.757
5,2026-01-16 15:31:56,13045.12,13.045
```

### Cleanup Function
The script includes aggressive cleanup:
- Kills all Calculator, Paint, Notepad processes
- Clears Notepad session state files
- Removes Notepad registry entries
- Ensures clean state for next iteration

## Integration with IDS Testing

### Option 1: Additional Performance Criterion
This is criterion (f) as an additional bonus test:
- **Metric**: Application launch performance
- **Measurement**: Time to launch 75 application instances per iteration (ms), 5 iterations
- **Total**: 375 application launches across all iterations
- **Rationale**: Tests IDS impact on process creation overhead

### Option 2: System Responsiveness Validation
Use this test to validate that the system remains responsive under IDS load:
- Run before baseline measurements
- Run after installing each IDS component
- Compare times to detect severe degradation

### Option 3: Replace/Supplement Process Count Test
Instead of just counting processes, this measures:
- Process creation speed
- System responsiveness under load
- Memory allocation performance

## How to Use for IDS Testing

### For Each Configuration:

1. **Restore VM snapshot**
   ```powershell
   VBoxManage snapshot "WIN11" restore "Baseline-NoIDS"
   ```

2. **Start VM and navigate to script**
   ```powershell
   cd C:\path\to\AV-Bench
   ```

3. **Run the script**
   ```powershell
   .\script.ps1
   ```

4. **Collect results**
   - Copy `measurements.csv` to project data folder
   - Rename: `app-launch-baseline.csv`, `app-launch-symantec.csv`, etc.

5. **Calculate averages**
   - Average of 5 iterations per configuration
   - Compare against baseline
   - Calculate overhead percentage

### Expected Results

**Baseline (No IDS)**:
- Expected: 8-15 seconds for 75 apps
- Variance: <10% across iterations

**With IDS**:
- AV overhead: 10-30% slower (process scanning)
- Firewall overhead: 5-15% slower (network startup)
- Combined: 15-40% slower

## Advantages of This Test

✅ **Real Application Load**: Uses actual Windows apps, not synthetic benchmarks  
✅ **Process Creation**: Tests IDS impact on process creation/scanning  
✅ **Memory Allocation**: Tests memory allocation under IDS  
✅ **Consistent State**: Aggressive cleanup ensures repeatability  
✅ **CSV Output**: Already formatted for analysis  
✅ **Automated**: No manual intervention needed

## Integration Recommendations

### If Using as Criterion (f):

Specification updated to include:
- **Criterion (f)**: Application launch performance (bonus)
- **Measurement**: Time to launch 75 application instances per iteration
- **Tools**: Custom PowerShell script (`AV-Bench/script.ps1`)
- **Iterations**: 5 per configuration (configured to match other tests)
- **Total Launches**: 375 application instances per configuration

### If Using as Validation:

Run this test once per configuration to verify:
- System is not severely degraded by IDS
- IDS is functioning without conflicts
- VM performance is stable

## Modifications Applied

The script has been updated to production configuration:

### 1. ✅ Iterations Set to 5 (matches other tests):
```powershell
$iterations = 5  # Already configured
```

### 2. Add Configuration Label:
```powershell
# At the top of script
param(
    [string]$ConfigName = "Baseline"
)

# In CSV output section
$outputFile = Join-Path $scriptPath "measurements-$ConfigName.csv"
```

### 3. Reduce Wait Time Between Iterations:
```powershell
Start-Sleep -Seconds 3  # Change from 5 to 3
```

## Comparison with Other Criteria

| Criterion | What It Measures | This Script Measures |
|-----------|------------------|---------------------|
| (a) SMB Copy | Network transfer speed | Static file transfer |
| (b) FTP Download | Remote download speed | Static remote transfer |
| (c) Process Count | Static process count at startup | Current (criterion c) |
| (d) RAM Usage | Static memory at startup | Current (criterion d) |
| (e) Boot Time | OS initialization | Current (criterion e) |
| **(f) App Launch** | **Real-world responsiveness** | **375 app startups** |
| (g) sysbench | Synthetic CPU/mem/disk | Synthetic benchmarks |

## Usage Commands

### Basic Run:
```powershell
cd C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\AV-Bench
.\script.ps1
```

### Modified Run (with config name):
```powershell
.\script.ps1 -ConfigName "Baseline-NoIDS"
.\script.ps1 -ConfigName "Symantec-Only"
.\script.ps1 -ConfigName "OPNsense-Only"
.\script.ps1 -ConfigName "Symantec-OPNsense-Both"
```

### Copy Results to Project:
```powershell
Copy-Item "AV-Bench\measurements.csv" "data\baseline\app-launch-baseline.csv"
Copy-Item "AV-Bench\measurements.csv" "data\symantec\app-launch-symantec.csv"
Copy-Item "AV-Bench\measurements.csv" "data\opnsense\app-launch-opnsense.csv"
Copy-Item "AV-Bench\measurements.csv" "data\both\app-launch-both.csv"
```

## Analysis

### Calculate Overhead:
```powershell
# Load CSVs
$baseline = Import-Csv "data\baseline\app-launch-baseline.csv"
$symantec = Import-Csv "data\symantec\app-launch-symantec.csv"

# Calculate averages
$baselineAvg = ($baseline | Measure-Object -Property TimeSeconds -Average).Average
$symantecAvg = ($symantec | Measure-Object -Property TimeSeconds -Average).Average

# Calculate overhead
$overhead = (($symantecAvg - $baselineAvg) / $baselineAvg) * 100
Write-Host "Symantec overhead: $([math]::Round($overhead, 2))%"
```

## Rationale for Paper

"Application launch performance (criterion f) was measured by timing the sequential startup of 75 application instances (25 each of Calculator, Paint, and Notepad) in randomized order across 5 iterations, totaling 375 application launches per configuration. This test evaluates the real-world impact of IDS process scanning on application startup times, memory allocation, and system responsiveness under moderate concurrent process creation load. Unlike static measurements, this dynamic test reveals the practical overhead users experience when launching applications with active IDS protection."

## Recommendation

**Consider using this as:**
1. **Primary test** instead of simple process counting (criterion c)
2. **Additional criterion (g)** for extra bonus points
3. **Validation test** to ensure system health across configurations

The script is well-written, automated, and provides valuable performance insights beyond static measurements.
