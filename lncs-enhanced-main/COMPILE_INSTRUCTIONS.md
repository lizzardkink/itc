# IDS Performance Paper - LaTeX Compilation Guide

## Files Created

- `ids-performance-paper.tex` - Main paper document
- `ids-paper.bib` - Bibliography file
- Figures already in `../figures/` directory

## Requirements

- LaTeX distribution (TeX Live or MiKTeX)
- LuaLaTeX compiler (recommended)
- BibTeX for bibliography

## Compilation Instructions

### Option 1: Using latexmk (Recommended)

```bash
latexmk -pdflua ids-performance-paper.tex
```

### Option 2: Manual Compilation

```bash
lualatex ids-performance-paper.tex
bibtex ids-performance-paper
lualatex ids-performance-paper.tex
lualatex ids-performance-paper.tex
```

### Option 3: Using PDFLaTeX (if LuaLaTeX unavailable)

Edit line 5 of the .tex file: change `lualatex` to `pdflatex`

```bash
pdflatex ids-performance-paper.tex
bibtex ids-performance-paper
pdflatex ids-performance-paper.tex
pdflatex ids-performance-paper.tex
```

## Quick Compilation Script

### Windows (PowerShell)
```powershell
.\Compile-Paper.ps1
```

### Linux/Mac
```bash
./compile-paper.sh
```

## Document Structure

1. **Abstract** - Summary of study and key findings
2. **Introduction** - Research questions and contributions
3. **Related Work** - Methodology background
4. **Methodology** - Test environment, configurations, metrics, statistics
5. **Results** - Six performance criteria with tables and figures:
   - Boot Time (Table 1, Figure 1)
   - RAM Usage (Table 2, Figure 2)
   - Process Count (Table 3)
   - App Launch (Table 4, Figure 3)
   - Network (Tables 5-6, Figure 4)
   - Overview (Table 7, Figure 5)
6. **Discussion** - Analysis and recommendations
7. **Conclusion** - Summary and implications

## Key Features

✅ LNCS two-column format  
✅ 6 high-quality figures (PDF format)  
✅ 7 statistical tables  
✅ Professional academic styling  
✅ Proper citations and bibliography  
✅ Estimated 9-10 pages with figures  

## Figures Reference

All figures are in `../figures/` directory:
- `chart1_boot_time.pdf`
- `chart2_ram_usage.pdf`
- `chart3_app_launch.pdf`
- `chart4_network_performance.pdf`
- `chart5_comprehensive_overhead.pdf`
- `chart6_process_count.pdf` (optional, not included in main paper)

## Customization

### Author Information
Edit lines 92-96 in `ids-performance-paper.tex`:
```latex
\author{Your Name}
\institute{Your University Name\\
\email{your.email@university.edu}}
```

### Title
Edit line 90 for shorter title if needed.

## Troubleshooting

**Issue**: "File not found: figures/chartX.pdf"  
**Solution**: Ensure figures directory is one level up from tex file

**Issue**: "Bibliography not found"  
**Solution**: Make sure `ids-paper.bib` is in same directory

**Issue**: Font errors with LuaLaTeX  
**Solution**: Use PDFLaTeX instead (see Option 3)

## Final Checks

- [ ] Author name and institution updated
- [ ] Email address updated
- [ ] All 6 figures compile correctly
- [ ] Bibliography renders properly
- [ ] Document is 9-10 pages
- [ ] No compilation errors or warnings

## Output

Successful compilation produces:
- `ids-performance-paper.pdf` - Final paper (9-10 pages)
- `ids-performance-paper.aux` - Auxiliary file
- `ids-performance-paper.bbl` - Bibliography file
- `ids-performance-paper.log` - Compilation log

Good luck with your submission!
