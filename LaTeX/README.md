# IDS Performance Paper - Minimal LaTeX Distribution

This folder contains the **minimal set of files** needed to compile the IDS performance paper without the clutter of the full template.

## 📁 Folder Contents

### Core Files (4 files)
- `ids-performance-paper.tex` - Main paper document
- `ids-paper.bib` - Bibliography file
- `llncs.cls` - LNCS document class (required)
- `splncs04nat.bst` - Bibliography style (required)

### Figures (6 files in `figures/` subdirectory)
- `chart1_boot_time.pdf`
- `chart2_ram_usage.pdf`
- `chart3_app_launch.pdf`
- `chart4_network_performance.pdf`
- `chart5_comprehensive_overhead.pdf`
- `chart6_process_count.pdf` (not used in paper, but available)

### Compilation Script
- `compile.ps1` - Simple PowerShell compilation script

## 🚀 Quick Start

### Windows (PowerShell)
```powershell
.\compile.ps1
```

### Manual Compilation
```bash
lualatex ids-performance-paper.tex
bibtex ids-performance-paper
lualatex ids-performance-paper.tex
lualatex ids-performance-paper.tex
```

## 📊 What's in the Paper

**Title**: Performance Impact Analysis of Intrusion Detection/Prevention Systems on Windows 11: A Comparative Study of TotalAV and Fort Firewall

**Author**: Robert Molnar  
**Institution**: West University of Timișoara  
**Email**: robert.molnar81@e-uvt.ro

### Key Findings
- TotalAV: +50.05% application launch overhead (worst impact)
- Fort Firewall: -14.62% boot time improvement (unexpected!)
- Combined IDS: subadditive effects in several metrics
- Network degradation: 8.80-20.02% across all configurations

### Content
- 13 pages in LNCS two-column format
- 7 statistical tables with measurement data
- 6 high-quality figures (300 DPI PDF)
- 5 references to industry standards (Tom's Hardware, AnandTech, Tukey)

## ✅ Compilation Requirements

- **LaTeX Distribution**: TeX Live or MiKTeX
- **Compiler**: LuaLaTeX (recommended) or PDFLaTeX
- **BibTeX**: For bibliography processing

## 📝 Customization

To modify author information, edit lines 84-88 in `ids-performance-paper.tex`:

```latex
\author{Your Name}
\institute{Your Institution\\
\email{your.email@domain.edu}}
```

## 📦 Folder Size

- **Total files**: 16 (excluding compilation outputs)
- **Total size**: ~659 KB
- **No unnecessary template files** ✓
- **No build artifacts** (clean folder) ✓

## 🎯 Comparison with Original Template

| Folder | Files | Size | Clutter |
|--------|-------|------|---------|
| `lncs-enhanced-main/` | 44 files | ~3 MB | Template files, configs, examples |
| `LaTeX/` | 16 files | 659 KB | **Essential files only** ✓ |

## 🔧 Output Files (after compilation)

Compilation generates these files:
- `ids-performance-paper.pdf` - Final paper (~250 KB)
- `ids-performance-paper.aux` - Auxiliary file
- `ids-performance-paper.bbl` - Compiled bibliography
- `ids-performance-paper.blg` - BibTeX log
- `ids-performance-paper.log` - Compilation log
- `ids-performance-paper.out` - Hyperref bookmarks

These can be safely deleted between compilations.

## ✨ Features

✅ **Minimal distribution** - only essential files  
✅ **Clean folder** - no template clutter  
✅ **Self-contained** - includes LNCS class and bibliography style  
✅ **All figures included** - ready to compile  
✅ **Simple compilation** - one PowerShell script  
✅ **Well documented** - clear README  

## 📅 Ready for Submission

**Deadline**: January 23, 2026  
**Status**: ✓ Paper complete and ready  
**Format**: LNCS conference proceedings  

---

**Last Updated**: January 19, 2026  
**Repository**: lizzardkink/itc (branch: 001-av-benchmark)
