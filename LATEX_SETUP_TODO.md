# LaTeX Template Setup - TODO List

**Status**: ❌ NOT READY - Missing critical files  
**Template**: Enhanced LNCS Template (lncs-enhanced-main)  
**Date Checked**: 2026-01-16

## Critical Issues

### 1. Missing LNCS Document Class File ❌

**Problem**: `llncs.cls` file not found in template directory

**Solution**:
1. Download official LNCS author package from Springer:
   - URL: https://www.springer.com/gp/computer-science/lncs/conference-proceedings-guidelines
   - Look for "LaTeX2e Proceedings Templates" or "llncs2e.zip"
2. Extract `llncs.cls` from the downloaded archive
3. Copy `llncs.cls` to: `C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\lncs-enhanced-main\`
4. Verify file is present with: `Test-Path llncs.cls`

**Alternative**: The file may be available in MiKTeX package repository:
```powershell
mpm --install=springer-llncs
```

### 2. Missing stfloats Package ❌

**Problem**: `stfloats.sty` not found - compilation fails

**Solution**:
Install via MiKTeX Package Manager:

**Option A - Command Line**:
```powershell
mpm --install=stfloats
```

**Option B - MiKTeX Console** (GUI):
1. Open MiKTeX Console
2. Go to "Packages" tab
3. Search for "stfloats"
4. Click "Install" or click the "+" button
5. Wait for installation to complete

### 3. LaTeXmk Configuration File ⚠️

**Problem**: `_latexmkrc` has underscore prefix (should be `.latexmkrc`)

**Solution**:
```powershell
cd C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\lncs-enhanced-main
Rename-Item "_latexmkrc" ".latexmkrc"
```

## Verification Steps

After completing the fixes above, verify the setup:

```powershell
# Navigate to template directory
cd C:\Users\lizzardkink\OneDrive\Documents\Dev\ItC\lncs-enhanced-main

# Check that llncs.cls exists
Test-Path llncs.cls

# Check that latexmk config is renamed
Test-Path .latexmkrc

# Attempt to compile
latexmk paper

# OR use lualatex directly
lualatex paper
bibtex paper
lualatex paper
lualatex paper
```

Expected output: `paper.pdf` should be generated without errors

## Alternative: Use Official LNCS Template

If the enhanced template has too many issues, download the official template specified in project requirements:

```powershell
# Download and extract official template
$url = "https://github.com/latextemplates/LNCS/archive/main.zip"
Invoke-WebRequest -Uri $url -OutFile "LNCS-main.zip"
Expand-Archive "LNCS-main.zip" -DestinationPath "."
```

The official template should have all necessary files included.

## LaTeX Distribution Requirements

**Detected**: MiKTeX installed at `C:\Program Files\MiKTeX`

**Required Tools**:
- ✓ lualatex (should be included with MiKTeX)
- ✓ bibtex (should be included with MiKTeX)
- ✓ latexmk (requires Perl - may need separate installation)

**Check LaTeX Installation**:
```powershell
lualatex --version
bibtex --version
latexmk --version
```

## Template Structure (Current)

```
lncs-enhanced-main/
├── paper.tex           ✓ Main document
├── paper.bib           ✓ Bibliography database
├── splncs04nat.bst     ✓ Bibliography style
├── commands.tex        ✓ Custom commands
├── _latexmkrc          ⚠️ Needs rename to .latexmkrc
├── llncs.cls           ❌ MISSING - CRITICAL
└── (stfloats.sty)      ❌ MISSING - via MiKTeX package
```

## Next Steps for IDS Research Project

Once LaTeX is working:

1. **Copy template to project**: Consider creating a clean copy for the IDS paper
   ```powershell
   Copy-Item -Path "lncs-enhanced-main" -Destination "ids-paper" -Recurse
   ```

2. **Rename for project**: 
   - Rename `paper.tex` → `ids-impact-analysis.tex`
   - Update bibliography with IDS-related references

3. **Start writing**: Begin with methodology section documenting test setup

4. **Track in git**: Ensure LaTeX sources are version controlled
   ```powershell
   cd ids-paper
   git init
   git add .
   git commit -m "Initial LaTeX template setup for IDS paper"
   ```

## References

- **Springer LNCS Guidelines**: https://www.springer.com/gp/computer-science/lncs/conference-proceedings-guidelines
- **Enhanced Template GitHub**: https://github.com/latextemplates/scientific-thesis-template
- **Official LNCS Template**: https://github.com/latextemplates/LNCS
- **MiKTeX Package Manager**: https://miktex.org/howto/miktex-console
- **LaTeXmk Documentation**: https://mg.readthedocs.io/latexmk.html

## Status Summary

| Component | Status | Action Required |
|-----------|--------|-----------------|
| paper.tex | ✓ Present | None |
| paper.bib | ✓ Present | None |
| llncs.cls | ❌ Missing | Download from Springer |
| stfloats.sty | ❌ Missing | Install via MiKTeX |
| .latexmkrc | ⚠️ Wrong name | Rename from _latexmkrc |
| MiKTeX | ✓ Installed | Verify packages |
| Compilation | ❌ Failed | Fix above issues first |

**Ready for Use**: NO - Fix critical issues first
