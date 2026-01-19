# Compile IDS Performance Paper
# Simple compilation script for minimal LaTeX folder

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "IDS Performance Paper - LaTeX Compilation" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$texFile = "ids-performance-paper"

# Check for LaTeX compiler
$compiler = $null
if (Get-Command lualatex -ErrorAction SilentlyContinue) {
    $compiler = "lualatex"
    Write-Host "✓ Using LuaLaTeX" -ForegroundColor Green
} elseif (Get-Command pdflatex -ErrorAction SilentlyContinue) {
    $compiler = "pdflatex"
    Write-Host "✓ Using PDFLaTeX" -ForegroundColor Green
} else {
    Write-Host "✗ No LaTeX compiler found!" -ForegroundColor Red
    Write-Host "Please install TeX Live or MiKTeX" -ForegroundColor Red
    exit 1
}

Write-Host "`nCompiling...`n" -ForegroundColor Cyan

# Compilation steps
& $compiler -interaction=nonstopmode "$texFile.tex" | Out-Null
& bibtex "$texFile" | Out-Null
& $compiler -interaction=nonstopmode "$texFile.tex" | Out-Null
& $compiler -interaction=nonstopmode "$texFile.tex" | Out-Null

# Check result
if (Test-Path "$texFile.pdf") {
    Write-Host "✓ Compilation successful!" -ForegroundColor Green
    $pdfSize = (Get-Item "$texFile.pdf").Length / 1KB
    Write-Host "Generated: $texFile.pdf ($([math]::Round($pdfSize, 2)) KB)" -ForegroundColor Green
    
    Write-Host "`nOpening PDF..." -ForegroundColor Cyan
    Start-Process "$texFile.pdf"
} else {
    Write-Host "✗ Compilation failed!" -ForegroundColor Red
    Write-Host "Check $texFile.log for errors" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
