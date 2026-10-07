$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot

Write-Host "== Archer AI Pet EXE Builder ==" -ForegroundColor Cyan

function Assert-Command($Name, $DisplayName) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "$DisplayName was not found in PATH. Please install it and try again."
    }
}

try {
    Write-Host "Checking Python..." -ForegroundColor Yellow
    Assert-Command "python" "Python"

    Write-Host "Installing PyInstaller..." -ForegroundColor Yellow
    python -m pip install --upgrade pip
    python -m pip install PyInstaller

    Write-Host "Building standalone EXE..." -ForegroundColor Yellow
    $appMain = Join-Path $ProjectRoot "app" "main.py"
    
    pyinstaller --onefile `
        --windowed `
        --name "ArcherAIPet" `
        --icon "$env:SystemRoot\System32\SHELL32.dll" `
        --add-data "data:data" `
        --add-data "assets:assets" `
        --hidden-import=PySide6 `
        --hidden-import=requests `
        --hidden-import=pyttsx3 `
        --hidden-import=speech_recognition `
        --collect-all PySide6 `
        $appMain

    $distDir = Join-Path $ProjectRoot "dist"
    $exePath = Join-Path $distDir "ArcherAIPet.exe"

    if (Test-Path $exePath) {
        Write-Host "Build successful!" -ForegroundColor Green
        Write-Host "EXE location: $exePath" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "You can now run the EXE directly without Python installed." -ForegroundColor Green
        Write-Host "Copy the entire 'dist' folder to distribute the app." -ForegroundColor Green
    } else {
        throw "EXE was not created. Check the build log above for errors."
    }

} catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
}
