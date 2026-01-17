# Invoke-VMCommand.ps1
# Helper script for executing commands on WIN11 VM via VirtualBox Guest Control
# UPDATED: 2026-01-16 - Now uses VBoxManage instead of WinRM for reliability

<#
.SYNOPSIS
    Execute commands or scripts on the WIN11 VM via VirtualBox Guest Control.

.DESCRIPTION
    Simplifies remote command execution on WIN11 VM using VBoxManage guestcontrol.
    More reliable than WinRM as it works directly through VirtualBox Guest Additions.

.PARAMETER Command
    PowerShell command string to execute on the remote VM.

.PARAMETER ScriptPath
    Path to a script file on the VM to execute (use Z:\ for shared folder scripts).

.PARAMETER Interactive
    Opens an interactive PowerShell session to the VM.

.EXAMPLE
    .\Invoke-VMCommand.ps1 -Command "hostname; Get-Process | Select -First 5"

.EXAMPLE
    .\Invoke-VMCommand.ps1 -ScriptPath "Z:\scripts\process-count-test.ps1"

.EXAMPLE
    .\Invoke-VMCommand.ps1 -Interactive
#>

param(
    [Parameter(ParameterSetName='Command')]
    [string]$Command,
    
    [Parameter(ParameterSetName='ScriptPath')]
    [string]$ScriptPath,
    
    [Parameter(ParameterSetName='Interactive')]
    [switch]$Interactive,
    
    [string]$VMName = "WIN11",
    [string]$Username = "admin",
    [string]$Password = "admin"
)

$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# Verify VBoxManage exists
if (-not (Test-Path $VBoxManage)) {
    Write-Error "VBoxManage.exe not found at: $VBoxManage"
    exit 1
}

# Verify VM is running
Write-Host "Checking VM status..." -ForegroundColor Cyan
$vmInfo = & $VBoxManage showvminfo $VMName --machinereadable 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to get VM info. Is VM name correct? ($VMName)"
    exit 1
}

$vmState = ($vmInfo | Select-String 'VMState="(.+)"').Matches.Groups[1].Value
if ($vmState -ne "running") {
    Write-Error "VM is not running. Current state: $vmState"
    exit 1
}

Write-Host "VM is running" -ForegroundColor Green

# Execute based on parameter set
if ($Interactive) {
    Write-Host "Opening interactive session to WIN11 VM..." -ForegroundColor Cyan
    Write-Host "Type 'exit' to close the session." -ForegroundColor Yellow
    & $VBoxManage guestcontrol $VMName --username $Username --password $Password run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe -NoExit
}
elseif ($ScriptPath) {
    Write-Host "Executing script: $ScriptPath" -ForegroundColor Cyan
    & $VBoxManage guestcontrol $VMName --username $Username --password $Password run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe -ExecutionPolicy Bypass -File $ScriptPath
}
elseif ($Command) {
    Write-Host "Executing remote command..." -ForegroundColor Cyan
    & $VBoxManage guestcontrol $VMName --username $Username --password $Password run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe -Command $Command
}
else {
    Write-Host "No action specified. Use -Command, -ScriptPath, or -Interactive" -ForegroundColor Red
    Get-Help $MyInvocation.MyCommand.Path
}
