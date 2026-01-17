# PowerShell Remoting Setup for WIN11 VM (NAT)

**Updated**: 2026-01-16 17:14 UTC  
**Purpose**: Enable remote PowerShell access from host to WIN11 VM over NAT networking

## Step 1: Inside the WIN11 VM Guest

Open **PowerShell as Administrator** and run these commands:

```powershell
# Enable PowerShell Remoting
Enable-PSRemoting -Force

# Allow connections from any host (needed for NAT)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Verify WinRM service is running
Get-Service WinRM

# Check firewall rules were created
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP"

# Optional: Create local admin user if needed
# net user admin admin /add
# net localgroup administrators admin /add

# Get the VM's current IP (for verification)
ipconfig | Select-String "IPv4"
```

**Expected output**: WinRM service should be "Running"

## Step 2: On the Host Computer (This Machine)

### A. Set up NAT port forwarding in VirtualBox

```powershell
# Forward host port 5985 to guest port 5985 (HTTP/WinRM)
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "WIN11" --natpf1 "winrm,tcp,,5985,,5985"

# Verify the rule was created
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" showvminfo WIN11 | Select-String "NIC 1 Rule"
```

**Note**: The VM must be powered off to add port forwarding rules, or use `controlvm` instead of `modifyvm` if running.

### B. Configure host to trust the VM

```powershell
# Add localhost to trusted hosts (allows connecting to 127.0.0.1)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "localhost,127.0.0.1" -Force

# Verify
Get-Item WSMan:\localhost\Client\TrustedHosts
```

### C. Test the connection

```powershell
# Create credential object
$cred = Get-Credential -UserName "admin" -Message "Enter password for admin"

# Test connection
Test-WSMan -ComputerName localhost -Port 5985 -Credential $cred

# Enter remote session
Enter-PSSession -ComputerName localhost -Port 5985 -Credential $cred

# Once connected, you'll see [localhost]: PS C:\Users\admin>
# Test with: hostname
# Exit with: Exit-PSSession
```

## Step 3: Running Remote Commands

### Single command:
```powershell
Invoke-Command -ComputerName localhost -Port 5985 -Credential $cred -ScriptBlock { 
    Get-Process | Select-Object -First 5 
}
```

### Interactive session:
```powershell
Enter-PSSession -ComputerName localhost -Port 5985 -Credential $cred
# Now you're in the VM
[localhost]: hostname
[localhost]: Get-Service WinRM
[localhost]: Exit-PSSession
```

## Troubleshooting

### If connection fails:

**In the VM:**
```powershell
# Restart WinRM service
Restart-Service WinRM

# Check if port 5985 is listening
netstat -an | Select-String "5985"

# Verify firewall rules
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Get-NetFirewallPortFilter
```

**On the host:**
```powershell
# Test if port is accessible
Test-NetConnection -ComputerName localhost -Port 5985

# Check VirtualBox port forwarding
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" showvminfo WIN11 | Select-String "Rule"
```

### Common Issues:

1. **"Access is denied"** - Make sure you're using admin credentials
2. **"WinRM cannot process the request"** - Check TrustedHosts on both machines
3. **Connection timeout** - Verify port forwarding is configured and VM is running
4. **Authentication error** - Use explicit credentials with `-Credential` parameter

## Quick Reference

**Start remote session:**
```powershell
$cred = Get-Credential admin
Enter-PSSession -ComputerName localhost -Port 5985 -Credential $cred
```

**Run test scripts:**
```powershell
Invoke-Command -ComputerName localhost -Port 5985 -Credential $cred -ScriptBlock {
    # Run test script in VM
    Z:\scripts\process-count-test.ps1 -ConfigName "baseline" -Iterations 5
}
```

---

**Security Note**: This configuration uses HTTP (not HTTPS) for simplicity in a local testing environment. For production, use HTTPS with proper certificates.
