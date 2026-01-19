# Performance Impact Analysis of Intrusion Detection Systems on Windows 11: A Comparative Study of TotalAV and Fort Firewall

**Authors**: Robert Molnar  
**Institution**: [Your University]  
**Date**: January 2026

---

## Abstract

This study quantifies the computational overhead of intrusion detection systems (IDS) on Windows 11 through systematic benchmarking of TotalAV antivirus (v6.5.219) and Fort Firewall (v3.19.9). Four configurations were evaluated: baseline (no IDS), TotalAV-only, Fort Firewall-only, and combined deployment. Six performance metrics were measured across five iterations: boot time, RAM consumption, process count, application launch, local network throughput (SMB), and remote download speed (FTP). Statistical analysis using Interquartile Range (IQR) outlier detection revealed significant patterns. TotalAV imposed the highest overhead at 31.39% increased boot time, 17.44% higher RAM usage, and 50.05% slower application launches. Surprisingly, Fort Firewall improved boot time by 14.62% and application launch by 18.05%, suggesting optimization benefits over Windows' built-in firewall. Network performance degraded 8.80-20.02% across all IDS configurations. Results indicate that while IDS software provides essential security, careful consideration of performance trade-offs is necessary for resource-constrained environments.

**Keywords**: Intrusion Detection System, Antivirus, Firewall, Performance Benchmarking, Windows 11

---

## 1. Introduction

Modern computing environments require Intrusion Detection Systems (IDS) including antivirus and firewalls for cybersecurity protection. However, these solutions consume computational resources, creating performance trade-offs that impact user experience. This study quantifies the performance overhead of TotalAV antivirus and Fort Firewall on Windows 11, providing empirical data for informed deployment decisions.

### Research Questions

**RQ1**: What computational overhead does TotalAV antivirus impose on Windows 11 system performance?  
**RQ2**: How does Fort Firewall affect system performance compared to baseline and antivirus-only configurations?  
**RQ3**: Do combined IDS deployments exhibit additive, synergistic, or independent performance degradation patterns?  
**RQ4**: Which performance metrics are most severely impacted by IDS software?

### Contribution

This research provides empirically-derived performance metrics for contemporary IDS solutions on Windows 11 using standardized testing methodologies consistent with industry practices (Tom's Hardware, AnandTech). Unlike vendor-provided benchmarks, this independent evaluation enables data-driven decision-making for security policy development and capacity planning.

---

## 2. Related Work

Computer performance evaluation methodologies established by Tom's Hardware and AnandTech emphasize controlled environments, multiple iteration testing, outlier detection, and comparative analysis against baseline configurations. Our methodology aligns with these principles, employing five iterations per test and applying Interquartile Range (IQR) outlier detection.

Previous antivirus performance studies reported overhead ranging from 10-40% on boot times and 5-20% on application performance. However, comprehensive comparative analysis of combined IDS deployments (antivirus + firewall) on Windows 11 virtualized environments remains limited. This study addresses that gap through controlled measurements across six distinct performance criteria.

---

## 3. Methodology

### 3.1 Test Environment

**Host System**: Lenovo ThinkPad with Intel Core i7-1185G7 (11th Gen, 4C/8T @ 3.0 GHz), 16 GB Samsung DDR4-4267 RAM, 1TB Kingston NVMe SSD, Windows 11 Pro.

**Virtual Machine**: Oracle VirtualBox 7.2.2, Windows 11 Pro (64-bit), 4 vCPUs, 8 GB RAM, 128 MB VRAM, bridged network adapter. Shared folder C:\VMShare (host) mapped to Z: (guest) for automated data collection.

**Rationale**: Virtualization enables perfect snapshot-based consistency between test configurations, ensuring identical starting conditions for each measurement.

### 3.2 Test Configurations

Four distinct configurations were evaluated:
1. **Baseline**: Clean Windows 11, no IDS
2. **TotalAV Only**: TotalAV v6.5.219 active, Windows Firewall disabled
3. **Fort Firewall Only**: Fort Firewall v3.19.9 active, Windows Defender disabled  
4. **Both IDS**: TotalAV + Fort Firewall operational simultaneously

Each configuration implemented as separate VirtualBox snapshot for perfect state restoration.

### 3.3 Performance Metrics

**Criterion A - Boot Time**: BootRacer tool measuring total boot time (Time to Logon + Logon to Desktop). 5 boot cycles per configuration.

**Criterion B - RAM Consumption**: Windows Performance Monitor measuring used memory (MB) 30 seconds post-boot. 5 measurements per configuration.

**Criterion C - Process Count**: PowerShell Get-Process counting active processes 30 seconds post-boot. 5 measurements per configuration.

**Criterion D - Application Launch**: Custom PowerShell script launching 30 applications (10 Calculator, 10 Paint, 10 Notepad) per iteration, measuring total time. 5 iterations per configuration (150 total app launches).

**Criterion E - SMB Network Transfer**: Server Message Block protocol copying 1.01 GB folder from QNAP NAS (192.168.50.99) over 1 Gbps LAN, measuring transfer speed (MB/s). 5 iterations per configuration.

**Criterion F - FTP Remote Download**: FTP download of 114.66 MB file from DIGI Storage, measuring download speed (MB/s). 5 iterations per configuration.

### 3.4 Statistical Analysis

**Outlier Detection**: Interquartile Range (IQR) method applied to identify and remove statistical outliers:
```
Q1 = 25th percentile, Q3 = 75th percentile, IQR = Q3 - Q1
Lower bound = Q1 - 1.5 × IQR, Upper bound = Q3 + 1.5 × IQR
```

**Statistics Calculated**: Mean (μ), Median, Standard Deviation (σ), Coefficient of Variation (CV = σ/μ × 100%), Range [Min, Max].

**Overhead Calculation**: `Overhead (%) = ((Mean_IDS - Mean_baseline) / Mean_baseline) × 100%`

Positive values indicate degradation; negative values indicate improvement.

---

## 4. Results

### 4.1 Boot Time Performance

| Configuration | Mean (s) | Std Dev | CV (%) | Overhead (%) |
|--------------|----------|---------|--------|--------------|
| Baseline | 72.76 | 9.42 | 12.94 | — |
| TotalAV Only | 95.60 | 20.35 | 21.28 | **+31.39** |
| Fort Firewall Only | 62.12 | 10.16 | 16.35 | **-14.62** ✓ |
| Both IDS | 90.29 | 15.35 | 17.00 | +24.09 |

**Key Findings**: TotalAV imposed 31.39% boot penalty (72.76s → 95.60s). Fort Firewall paradoxically improved boot time by 14.62% (62.12s), suggesting more efficient initialization than Windows Firewall services. Combined deployment showed 24.09% overhead, less than TotalAV alone (non-additive effect).

### 4.2 RAM Consumption

| Configuration | Mean (MB) | Std Dev | CV (%) | Overhead (%) |
|--------------|-----------|---------|--------|--------------|
| Baseline | 2661.45 | 17.68 | 0.66 | — |
| TotalAV Only | 3125.62 | 62.72 | 2.01 | **+17.44** (+464 MB) |
| Fort Firewall Only | 2700.77 | 85.89 | 3.18 | +1.48 (+39 MB) |
| Both IDS | 3203.13 | 140.61 | 4.39 | +20.35 (+542 MB) |

**Key Findings**: TotalAV consumed 464 MB additional RAM, typical for modern antivirus with in-memory threat databases. Fort Firewall added minimal 39 MB, demonstrating efficient implementation. Combined overhead (542 MB) approximates sum of components (464 + 39 = 503 MB), indicating independent memory footprints.

### 4.3 Process Count

| Configuration | Mean | Std Dev | CV (%) | Overhead (%) |
|--------------|------|---------|--------|--------------|
| Baseline | 150.50 | 1.29 | 0.86 | — |
| TotalAV Only | 147.33 | 2.08 | 1.41 | **-2.10** ✓ |
| Fort Firewall Only | 152.00 | 0.00 | 0.00 | +1.00 |
| Both IDS | 151.00 | 0.00 | 0.00 | +0.33 |

**Key Findings**: Minimal variation (147-152 processes). TotalAV reduced count by 2.10%, suggesting efficient multi-threading or service consolidation. Low CV (0.00-1.41%) indicates highly consistent measurements.

### 4.4 Application Launch Performance

| Configuration | Mean (s) | Std Dev | CV (%) | Overhead (%) |
|--------------|----------|---------|--------|--------------|
| Baseline | 14.46 | 2.89 | 19.98 | — |
| TotalAV Only | 21.70 | 4.28 | 19.72 | **+50.05** |
| Fort Firewall Only | 11.85 | 2.24 | 18.93 | **-18.05** ✓ |
| Both IDS | 18.98 | 4.70 | 24.75 | +31.21 |

**Key Findings**: TotalAV imposed severe 50.05% penalty (14.46s → 21.70s), indicating aggressive real-time executable scanning. Fort Firewall improved performance by 18.05% (11.85s), consistent with boot time improvements. Combined deployment showed 31.21% overhead, significantly less than TotalAV alone, suggesting TotalAV remains dominant bottleneck.

### 4.5 Network Performance

**SMB Local Network Transfer (1 GB folder)**

| Configuration | Mean (MB/s) | Std Dev | CV (%) | Change (%) |
|--------------|-------------|---------|--------|------------|
| Baseline | 39.37 | 5.20 | 13.22 | — |
| TotalAV Only | 31.79 | 6.72 | 21.13 | **-19.26** |
| Fort Firewall Only | 42.18 | 9.26 | 21.94 | **+7.14** ✓ |
| Both IDS | 35.91 | 6.56 | 18.27 | -8.80 |

**FTP Remote Download (114.66 MB file)**

| Configuration | Mean (MB/s) | Std Dev | CV (%) | Change (%) |
|--------------|-------------|---------|--------|------------|
| Baseline | 10.29 | 1.59 | 15.42 | — |
| TotalAV Only | 9.18 | 1.32 | 14.43 | -10.83 |
| Fort Firewall Only | 8.50 | 1.95 | 22.93 | **-17.41** |
| Both IDS | 8.23 | 1.63 | 19.85 | **-20.02** |

**Key Findings**: TotalAV reduced SMB throughput by 19.26% due to real-time file scanning. Fort Firewall improved SMB by 7.14%, exceeding baseline through efficient packet processing. However, Fort Firewall imposed highest FTP penalty (-17.41%), suggesting deep packet inspection overhead for external connections differs from local LAN behavior. Combined deployment showed approximately additive FTP degradation (-20.02%).

### 4.6 Comprehensive Overview

| Metric | TotalAV Only | Fort Firewall Only | Both IDS |
|--------|-------------|-------------------|----------|
| Boot Time | +31.39% | **-14.62%** ✓ | +24.09% |
| RAM Usage | +17.44% | +1.48% | +20.35% |
| Process Count | -2.10% | +1.00% | +0.33% |
| App Launch | +50.05% | **-18.05%** ✓ | +31.21% |
| SMB Speed | -19.26% | **+7.14%** ✓ | -8.80% |
| FTP Speed | -10.83% | -17.41% | -20.02% |

**Overhead Categories**:
- 🔴 **Severe (>20%)**: TotalAV boot (+31.39%), app launch (+50.05%), both FTP (-20.02%)
- 🟡 **Moderate (10-20%)**: TotalAV RAM (+17.44%), SMB (-19.26%), Fort FTP (-17.41%), both RAM (+20.35%)
- 🟢 **Minimal (<10%)**: Fort RAM (+1.48%), all process counts, TotalAV FTP (-10.83%), both SMB (-8.80%)
- ✅ **Improved**: Fort boot (-14.62%), app launch (-18.05%), SMB (+7.14%)

---

## 5. Discussion

### 5.1 TotalAV Performance Impact

TotalAV demonstrated significant overhead across nearly all metrics:

**Application Launch (+50.05%)**: Doubling of launch time reflects aggressive real-time executable scanning, prioritizing security over responsiveness. Each of 30 application launches triggered antivirus inspection, accumulating substantial delay.

**Boot Time (+31.39%)**: The 23-second delay (72.76s → 95.60s) reflects antivirus service initialization, signature database loading, and initial system scan. Acceptable for infrequently-rebooted workstations but problematic for mobile devices.

**SMB Transfer (-19.26%)**: File transfer degradation stems from real-time on-access scanning creating I/O bottlenecks proportional to file count.

**RAM Overhead (+17.44%, 464 MB)**: Consistent with modern antivirus architectures maintaining resident threat databases, heuristic engines, and machine learning models.

### 5.2 Fort Firewall Characteristics

Fort Firewall exhibited unexpectedly positive performance in several metrics:

**Boot/App Launch Improvements**: The 10-second faster boot and 2.6-second reduction in app launch may result from efficient application whitelisting or reduced protocol stack overhead compared to Windows Firewall. This counterintuitive result warrants investigation into Windows Firewall service overhead.

**SMB Improvement (+7.14%)**: Throughput increase indicates more efficient packet processing than Windows built-in firewall through optimized buffering or reduced context switching.

**FTP Penalty (-17.41%)**: Highest among all configurations, suggesting deep packet inspection or connection state tracking overhead for external traffic differs significantly from local LAN.

### 5.3 Combined Deployment Interactions

**Subadditive Effects**: Boot time (24.09% vs. expected 16.77%) and app launch (31.21% vs. expected 32.00%) showed less overhead than sum of individual components, suggesting shared Windows security APIs reducing redundant system calls or Fort Firewall whitelisting TotalAV processes.

**Additive Effects**: RAM usage (20.35% vs. expected 18.92%) and FTP performance (-20.02% vs. -28.24%) remained largely independent, with separate memory pools and independent bottlenecks (antivirus I/O + firewall packet inspection).

### 5.4 Practical Recommendations

**Performance-Critical Environments**: Fort Firewall demonstrated negligible or positive impact across most metrics except FTP. Organizations prioritizing performance may consider firewall-only deployments with network-based antivirus.

**Security-Critical Environments**: Full IDS deployment recommended despite 20-31% overhead in time-sensitive operations. Combined 542 MB RAM overhead remains manageable on modern 8+ GB systems.

**Mobile/Battery-Constrained Devices**: 31% boot penalty and 50% app launch overhead may be unacceptable. Consider scheduled scanning during idle periods rather than real-time protection.

**Network-Intensive Workloads**: 19-20% file transfer degradation may be problematic for file servers. Network-based antivirus or scheduled offline scanning may be preferable.

### 5.5 Limitations

**Virtualization Overhead**: VirtualBox introduces baseline penalty (estimated 5-15%) compared to bare-metal. While this affects absolute values, relative comparisons remain valid.

**Network Variability**: FTP tests showed higher CV (14-23%) due to Internet fluctuations. Local FTP server simulation would provide more stable results.

**Workload Representativeness**: 30-application test (Calculator, Paint, Notepad) may not reflect enterprise applications with database connections and network authentication.

**Sample Size**: Five iterations meet minimum requirements, but n=10-20 would improve confidence intervals.

---

## 6. Conclusion

This study quantified TotalAV antivirus and Fort Firewall performance impact on Windows 11 through rigorous benchmarking. TotalAV imposed moderate-to-severe overhead (10.83-50.05%), with most significant impact on application launch (+50.05%) and boot time (+31.39%). Fort Firewall demonstrated unexpected improvements in boot time (-14.62%), application launch (-18.05%), and local network transfers (+7.14%), challenging assumptions about security software overhead.

Combined deployments showed subadditive effects in several metrics, suggesting architectural synergies. Network performance degraded across all IDS configurations (8.80-20.02%), indicating both antivirus I/O scanning and firewall packet inspection contribute independent bottlenecks.

Organizations must balance security requirements against performance through careful product selection and workload-appropriate deployment strategies. The quantitative metrics provided enable data-driven security policy development and capacity planning. Fort Firewall's performance improvements suggest opportunities for optimization in mainstream security products.

---

## References

1. **Tom's Hardware**. "How We Test: CPU and System Benchmarking Methodology." https://www.tomshardware.com/reviews/cpu-hierarchy,4312.html

2. **AnandTech**. "The AnandTech Benchmark Suite and Testing Methodology." https://www.anandtech.com/bench/CPU-2020

3. **Tom's Hardware**. "Antivirus Performance Impact Testing 2023." https://www.tomshardware.com/reviews/antivirus-performance-impact

4. **Tukey, J. W.** "Exploratory Data Analysis." Addison-Wesley, 1977.

5. **Box, G. E. P., Hunter, W. G., & Hunter, J. S.** "Statistics for Experimenters: Design, Innovation, and Discovery." Wiley-Interscience, 2005.

---

**END OF PAPER**

*Estimated length: 9-10 pages in LNCS format with 6 figures*
