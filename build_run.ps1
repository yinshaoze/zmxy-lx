# Build the run-only single-file executable (no init/Playwright).
# Usage: .\build_run.ps1
$ErrorActionPreference = 'Stop'

$py = 'python'
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    $py = 'C:\Users\yinsz\AppData\Local\Programs\Python\Python314\python.exe'
}

& $py -m pip install --quiet pyinstaller
& $py -m PyInstaller --onefile --name zmhj3 --hidden-import backends.private --clean --noconfirm run.py

Write-Host "Done: dist\zmhj3.exe"
