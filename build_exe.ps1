# Build main.py into a standalone executable (onedir).
# Usage: .\build_exe.ps1
$ErrorActionPreference = 'Stop'

$py = 'python'
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    $py = 'C:\Users\yinsz\AppData\Local\Programs\Python\Python314\python.exe'
}

& $py -m pip install --quiet pyinstaller
& $py -m PyInstaller --onedir --name main --hidden-import backends.private --clean --noconfirm main.py

Write-Host "Done: dist\main\main.exe"
