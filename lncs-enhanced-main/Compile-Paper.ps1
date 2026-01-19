# Compile IDS Performance Paper
# PowerShell script for Windows

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "IDS Performance Paper - LaTeX Compilation" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$texFile = "ids-performance-paper"

# Check if lualatex is available
Write-Host "Checking for LuaLaTeX..." -ForegroundColor Yellow
$luaLatexAvailable = Get-Command lualatex -ErrorAction SilentlyContinue

if ($luaLatexAvailable) {
    Write-Host "✓ LuaLaTeX found" -ForegroundColor Green
    $compiler = "lualatex"
} else {
    Write-Host "⚠ LuaLaTeX not found, trying PDFLaTeX..." -ForegroundColor Yellow
    $pdfLatexAvailable = Get-Command pdflatex -ErrorAction SilentlyContinue
    if ($pdfLatexAvailable) {
        Write-Host "✓ PDFLaTeX found" -ForegroundColor Green
        $compiler = "pdflatex"
    } else {
        Write-Host "✗ No LaTeX compiler found!" -ForegroundColor Red
        Write-Host "Please install TeX Live or MiKTeX" -ForegroundColor Red
        exit 1
    }
}

# Compilation steps
Write-Host "`nStarting compilation process...`n" -ForegroundColor Cyan

Write-Host "[1/4] First $compiler pass..." -ForegroundColor Yellow
& $compiler -interaction=nonstopmode "$texFile.tex" | Out-Null

Write-Host "[2/4] Running BibTeX..." -ForegroundColor Yellow
& bibtex "$texFile" | Out-Null

Write-Host "[3/4] Second $compiler pass..." -ForegroundColor Yellow
& $compiler -interaction=nonstopmode "$texFile.tex" | Out-Null

Write-Host "[4/4] Third $compiler pass..." -ForegroundColor Yellow
& $compiler -interaction=nonstopmode "$texFile.tex" | Out-Null

# Check if PDF was created
if (Test-Path "$texFile.pdf") {
    Write-Host "`n✓ Compilation successful!" -ForegroundColor Green
    Write-Host "`nGenerated: $texFile.pdf" -ForegroundColor Green
    
    # Get file size
    $pdfSize = (Get-Item "$texFile.pdf").Length / 1KB
    Write-Host "File size: $([math]::Round($pdfSize, 2)) KB" -ForegroundColor Green
    
    # Count pages
    Write-Host "`nOpening PDF..." -ForegroundColor Cyan
    Start-Process "$texFile.pdf"
} else {
    Write-Host "`n✗ Compilation failed!" -ForegroundColor Red
    Write-Host "Check $texFile.log for errors" -ForegroundColor Red
    exit 1
}

# Clean up auxiliary files (optional)
$cleanup = Read-Host "`nClean up auxiliary files? (y/n)"
if ($cleanup -eq 'y') {
    Remove-Item "$texFile.aux", "$texFile.log", "$texFile.out", "$texFile.bbl", "$texFile.blg" -ErrorAction SilentlyContinue
    Write-Host "✓ Cleanup complete" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
