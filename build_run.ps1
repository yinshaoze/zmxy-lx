# Build the run-only single-file executable (no init/Playwright).
# Usage: .\build_run.ps1
$py = 'python'
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    $py = 'C:\Users\yinsz\AppData\Local\Programs\Python\Python314\python.exe'
}

& $py -m pip install --quiet pyinstaller 2>&1 | Out-Null
& $py -m PyInstaller --onefile --name zmhj3 --hidden-import backends.private --clean --noconfirm --distpath build\out run.py 2>&1 | Out-Host
if ($LASTEXITCODE -ne 0) { Write-Host "PyInstaller failed: $LASTEXITCODE"; exit 1 }

New-Item -ItemType Directory -Force -Path dist | Out-Null
Copy-Item build\out\zmhj3.exe dist\zmhj3.exe -Force
Write-Host "Done: dist\zmhj3.exe"
