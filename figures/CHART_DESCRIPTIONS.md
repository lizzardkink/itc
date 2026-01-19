# Chart Descriptions for IDS Performance Impact Study

## Overview
Six professional publication-quality charts generated for the academic paper, available in both PNG (300 DPI) and PDF formats for flexibility in LaTeX compilation.

---

## Chart 1: Boot Time Comparison (`chart1_boot_time.*`)

**Type**: Grouped bar chart with error bars  
**Shows**: Total boot time (seconds) across all 4 configurations  
**Key Features**:
- Y-axis: Boot time in seconds (0-120s range)
- Error bars showing standard deviation
- Value labels on each bar (e.g., "72.8s")
- Percentage change annotations vs. baseline
- Color-coded by configuration (blue=baseline, purple=TotalAV, orange=Fort, red=both)

**Key Insight**: Fort Firewall improves boot time by 14.62% while TotalAV adds 31.39% overhead

---

## Chart 2: RAM Usage at Startup (`chart2_ram_usage.*`)

**Type**: Grouped bar chart with error bars  
**Shows**: Memory consumption (MB) at system startup  
**Key Features**:
- Y-axis: Memory usage in megabytes (0-3600 MB range)
- Error bars for measurement variance
- Value labels showing absolute MB values
- Overhead annotations showing "+464 MB (+17.44%)" format
- Consistent color scheme

**Key Insight**: TotalAV consumes 464 MB additional RAM, Fort Firewall only 39 MB

---

## Chart 3: Application Launch Performance (`chart3_app_launch.*`)

**Type**: Grouped bar chart with error bars  
**Shows**: Time to launch 30 applications (Calculator, Paint, Notepad)  
**Key Features**:
- Y-axis: Launch time in seconds
- Error bars for variability
- Percentage change annotations (red=slower, green=faster)
- Dramatic visualization of 50% TotalAV overhead

**Key Insight**: TotalAV doubles application launch time (+50.05%), Fort Firewall improves by 18.05%

---

## Chart 4: Network Performance (Dual Panel) (`chart4_network_performance.*`)

**Type**: Side-by-side bar charts  
**Left Panel**: SMB Local Network Transfer Speed (MB/s)  
**Right Panel**: FTP Remote Download Speed (MB/s)  
**Key Features**:
- Dual comparison showing local vs. remote network behavior
- Speed values in MB/s
- Percentage change annotations
- Shows contrasting behavior: Fort improves SMB (+7.14%) but degrades FTP (-17.41%)

**Key Insight**: Different network protocols show opposite performance patterns

---

## Chart 5: Comprehensive Overhead Heatmap (`chart5_comprehensive_overhead.*`)

**Type**: Color-coded heatmap matrix  
**Dimensions**: 5 metrics × 3 IDS configurations  
**Color Scale**: Green (improvements) → White (neutral) → Red (degradation)  
**Key Features**:
- Shows ALL performance metrics in single view
- Percentage values overlaid on each cell
- Easy identification of worst impacts (dark red) and improvements (dark green)
- White background for neutral/minimal changes

**Rows** (Metrics):
1. Boot Time
2. RAM Usage
3. App Launch
4. SMB Speed
5. FTP Speed

**Columns** (Configurations):
1. TotalAV Only
2. Fort Firewall Only
3. TotalAV + Fort Firewall

**Key Insight**: Comprehensive at-a-glance comparison revealing Fort Firewall's unique optimization benefits

---

## Chart 6: Process Count Comparison (`chart6_process_count.*`)

**Type**: Grouped bar chart  
**Shows**: Number of running processes at system startup  
**Key Features**:
- Y-axis: Process count (140-158 range for detail)
- Minimal variation visible (147-152 processes)
- Demonstrates efficient multi-threaded architecture of modern IDS
- Shows TotalAV actually reduces process count (-2.10%)

**Key Insight**: Modern IDS uses efficient threading rather than spawning many processes

---

## Chart Characteristics

### Technical Specifications
- **Resolution**: 300 DPI (publication quality)
- **Formats**: PNG (raster) + PDF (vector)
- **Color Scheme**: Colorblind-friendly palette
- **Font**: Times New Roman (serif, academic standard)
- **Size**: Optimized for LNCS two-column format

### Design Principles
✅ Professional academic style  
✅ Clear, readable labels at print size  
✅ Consistent color coding across all charts  
✅ Grid lines for precise value reading  
✅ Error bars showing measurement uncertainty  
✅ Annotations highlighting key findings  
✅ White backgrounds for print clarity

### Color Palette
- **Baseline**: Blue (#2E86AB) - neutral, reference
- **TotalAV**: Purple (#A23B72) - premium antivirus
- **Fort Firewall**: Orange (#F18F01) - warm, protective
- **Both IDS**: Red (#C73E1D) - combined, highest security

---

## Usage in LaTeX Paper

### Recommended Placement

1. **Chart 1 (Boot Time)**: Section 4.1 - Boot Time Performance
2. **Chart 2 (RAM Usage)**: Section 4.2 - RAM Consumption
3. **Chart 3 (App Launch)**: Section 4.4 - Application Launch Performance
4. **Chart 4 (Network)**: Section 4.5 & 4.6 - Network Performance (spans both SMB and FTP)
5. **Chart 5 (Heatmap)**: Section 4.7 - Comparative Performance Summary
6. **Chart 6 (Process Count)**: Section 4.3 - Process Count (or Appendix)

### LaTeX Figure Example

```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.9\columnwidth]{figures/chart1_boot_time.pdf}
\caption{Operating System Boot Time Across Four IDS Configurations. Error bars represent standard deviation across five boot iterations. Fort Firewall demonstrates unexpected 14.62\% improvement over baseline, while TotalAV imposes 31.39\% overhead.}
\label{fig:boot_time}
\end{figure}
```

---

## Statistical Validity Indicators

All charts include:
- **Error bars**: ±1 standard deviation showing measurement variability
- **Sample size**: n=5 for boot/RAM/process metrics, n=25 for app launch/network metrics
- **Outlier removal**: IQR method applied before visualization
- **Percentage changes**: Calculated from cleaned datasets
- **Baseline reference**: All comparisons against No IDS configuration

---

## Key Takeaways from Visual Analysis

📊 **Chart 1 + 3**: Fort Firewall shows counterintuitive IMPROVEMENTS  
📊 **Chart 2**: TotalAV's 464 MB RAM footprint is most significant resource consumption  
📊 **Chart 3**: 50% app launch overhead from TotalAV is the WORST single impact  
📊 **Chart 4**: Local vs. remote network shows different performance patterns  
📊 **Chart 5**: Heatmap reveals TotalAV dominates negative impact across metrics  
📊 **Chart 6**: Process count shows minimal variation (efficient modern IDS)

---

## File Information

**Location**: `C:\Users\lizzardkink\OneDrive\Documents\Dev\itc\figures\`

**File Sizes**:
- PNG files: 114-219 KB (high resolution)
- PDF files: 30-42 KB (vector, scalable)

**Total**: 12 files (6 charts × 2 formats)

**Recommendation**: Use PDF versions in LaTeX for crisp scaling and smaller document size. PNG versions available for PowerPoint presentations or web publication.
