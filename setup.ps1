# ====================================================================
# Setup Script for Skyrim Monitor Switcher
# ====================================================================
# Downloads NirCmd and prepares the environment
# ====================================================================

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Skyrim Monitor Switcher Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$nircmdUrl = "https://www.nirsoft.net/utils/nircmd.zip"
$nircmdZip = "$PSScriptRoot\nircmd.zip"
$nircmdExe = "$PSScriptRoot\nircmd.exe"

# Check if nircmd.exe already exists
if (Test-Path $nircmdExe) {
    Write-Host "[OK] NirCmd is already installed" -ForegroundColor Green
    Write-Host "    Location: $nircmdExe" -ForegroundColor Gray
} else {
    Write-Host "[...] Downloading NirCmd..." -ForegroundColor Yellow
    
    try {
        # Download NirCmd
        Invoke-WebRequest -Uri $nircmdUrl -OutFile $nircmdZip -UseBasicParsing
        Write-Host "[OK] Downloaded NirCmd" -ForegroundColor Green
        
        # Extract nircmd.exe
        Write-Host "[...] Extracting nircmd.exe..." -ForegroundColor Yellow
        Expand-Archive -Path $nircmdZip -DestinationPath $PSScriptRoot -Force
        
        # Move nircmd.exe from nested folder if needed
        $extractedPaths = @(
            "$PSScriptRoot\nircmd.exe",
            "$PSScriptRoot\nircmd\nircmd.exe",
            "$PSScriptRoot\nircmdc.exe"
        )
        
        $found = $false
        foreach ($path in $extractedPaths) {
            if (Test-Path $path) {
                if ($path -ne $nircmdExe) {
                    Move-Item -Path $path -Destination $nircmdExe -Force
                }
                $found = $true
                break
            }
        }
        
        if ($found) {
            Write-Host "[OK] NirCmd extracted successfully" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Could not find nircmd.exe in extracted files" -ForegroundColor Red
            Write-Host "        Please manually download from: $nircmdUrl" -ForegroundColor Yellow
        }
        
        # Cleanup
        if (Test-Path $nircmdZip) {
            Remove-Item $nircmdZip -Force
        }
        if (Test-Path "$PSScriptRoot\nircmd") {
            Remove-Item "$PSScriptRoot\nircmd" -Recurse -Force
        }
        
    } catch {
        Write-Host "[ERROR] Failed to download NirCmd: $_" -ForegroundColor Red
        Write-Host "        Please manually download from: $nircmdUrl" -ForegroundColor Yellow
        Write-Host "        Extract nircmd.exe to: $PSScriptRoot" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Configuration" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please edit SkyrimMonitorSwitcher.ahk to configure:" -ForegroundColor Yellow
Write-Host "  - GAME_MONITOR    : Monitor to use for Skyrim" -ForegroundColor Gray
Write-Host "  - DEFAULT_MONITOR : Monitor to restore after closing" -ForegroundColor Gray
Write-Host ""
Write-Host "To find your monitor numbers, use:" -ForegroundColor Cyan
Write-Host "  .\nircmd.exe setprimarydisplay 1" -ForegroundColor Gray
Write-Host "  .\nircmd.exe setprimarydisplay 2" -ForegroundColor Gray
Write-Host ""

# Check for AutoHotkey
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "AutoHotkey Installation" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$ahkInstalled = Get-Command "AutoHotkey.exe" -ErrorAction SilentlyContinue

if ($ahkInstalled) {
    Write-Host "[OK] AutoHotkey is installed" -ForegroundColor Green
} else {
    Write-Host "[!] AutoHotkey is NOT installed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please install AutoHotkey from:" -ForegroundColor Yellow
    Write-Host "  https://www.autohotkey.com/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or install via winget:" -ForegroundColor Yellow
    Write-Host "  winget install AutoHotkey.AutoHotkey" -ForegroundColor Gray
    Write-Host ""
    
    $install = Read-Host "Install AutoHotkey via winget now? (Y/N)"
    if ($install -eq "Y" -or $install -eq "y") {
        Write-Host "[...] Installing AutoHotkey..." -ForegroundColor Yellow
        winget install AutoHotkey.AutoHotkey
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Configure monitor numbers in SkyrimMonitorSwitcher.ahk" -ForegroundColor Gray
Write-Host "  2. Double-click SkyrimMonitorSwitcher.ahk to run" -ForegroundColor Gray
Write-Host "  3. Launch Skyrim SE to test" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
