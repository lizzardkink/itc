# Remote GUI Application Control on WIN11 VM

## Problem
When using PowerShell remoting to connect to WIN11 VM, all commands run in **Session 0** (non-interactive service session) which has no GUI access. GUI applications launched from remoting cannot display windows.

## Root Cause
- PowerShell remoting (WinRM) runs in Session 0
- GUI applications need Session 1 (or higher) - the active desktop session
- Explorer.exe runs in Session 1 on WIN11 VM
- Direct process creation from Session 0 → Session 1 is restricted

## Solution
Use a **helper script** that runs in Session 1 (desktop) and monitors for launch requests via file-based signaling.

### Architecture
```
Host Machine (Session 0) <--PowerShell Remoting--> VM (Session 0)
                                                     |
                                                File Trigger (Z:\gui_trigger.txt)
                                                     |
                                        VM Desktop (Session 1) <-- Helper Script
                                                     |
                                          GUI Apps (visible windows)
```

## Implementation

### Files Created
1. **Z:\GUI-App-Launcher-Helper.ps1** - Runs on VM in desktop session
   - Monitors Z:\gui_trigger.txt for requests
   - Launches apps in Session 1 with visible windows
   - Closes apps gracefully
   - Writes status to Z:\gui_processed.txt

2. **Invoke-RemoteGUIApp.ps1** - Run from host machine
   - Creates trigger files with launch/close requests
   - Waits for helper to process
   - Parameters: -AppName (notepad/mspaint/calc), -Action (Launch/CloseAll), -Count

### Setup Instructions

#### One-Time Setup (on VM)
1. Ensure auto-login is enabled (already configured)
2. Start the helper script from the VM desktop:
   ```powershell
   & 'Z:\GUI-App-Launcher-Helper.ps1'
   ```
   Or run minimized:
   ```powershell
   Start-Process powershell -ArgumentList '-File Z:\GUI-App-Launcher-Helper.ps1' -WindowStyle Minimized
   ```

#### Optional: Auto-start helper on login
Copy to Startup folder:
```powershell
Copy-Item 'Z:\GUI-App-Launcher-Helper.ps1' "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\"
```

### Usage Examples

#### Launch applications remotely
```powershell
# Launch 3 Paint instances
.\Invoke-RemoteGUIApp.ps1 -AppName mspaint -Action Launch -Count 3

# Launch 10 Notepad windows
.\Invoke-RemoteGUIApp.ps1 -AppName notepad -Action Launch -Count 10

# Launch 5 Calculator instances
.\Invoke-RemoteGUIApp.ps1 -AppName calc -Action Launch -Count 5
```

#### Close applications remotely
```powershell
# Close all Paint windows
.\Invoke-RemoteGUIApp.ps1 -AppName mspaint -Action CloseAll

# Close all Notepad windows  
.\Invoke-RemoteGUIApp.ps1 -AppName notepad -Action CloseAll
```

## How It Works

1. **Launch Request:**
   - Host creates JSON request file: `Z:\gui_trigger.txt`
   - Request contains: app name, action (Launch/CloseAll), count
   - Helper detects file, parses request
   - Helper launches apps using `Start-Process` in Session 1
   - Apps appear with visible windows on VM desktop
   - Helper writes success to: `Z:\gui_processed.txt`
   - Host detects processed file and confirms

2. **Close Request:**
   - Similar flow with action="CloseAll"
   - Helper calls `CloseMainWindow()` (graceful)
   - Force kills any remaining after 1 second timeout

## Verification Commands

### Check helper status
```powershell
Invoke-Command -ComputerName 127.0.0.1 -Port 5985 -Credential $cred -ScriptBlock {
    Get-Process -Name powershell,pwsh | ForEach-Object {
        $cmdLine = (Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)").CommandLine
        if ($cmdLine -like "*GUI-App-Launcher-Helper*") {
            "✓ Helper running: PID $($_.Id), Session $($_.SessionId)"
        }
    }
}
```

### Check active sessions
```powershell
Invoke-Command -ComputerName 127.0.0.1 -Port 5985 -Credential $cred -ScriptBlock {
    Get-Process -Name explorer | Select-Object Id, SessionId, ProcessName
}
```

### Manual test (verify apps launch in correct session)
```powershell
Invoke-Command -ComputerName 127.0.0.1 -Port 5985 -Credential $cred -ScriptBlock {
    # This launches in Session 0 (no window)
    Start-Process mspaint.exe -PassThru | Select-Object Id, SessionId
}
```

## Alternative Methods (Investigated but not used)

### Why NOT used:
1. **Scheduled Tasks** - Complex XML, unreliable for repeated launches
2. **PsExec** - Requires installation, external dependency
3. **WMI Win32_Process** - Cannot specify session, launches in Session 0
4. **VBScript** - Still launches in Session 0 when called from remoting
5. **Direct Start-Process with -WindowStyle** - Ignored in Session 0

### Why file-based signaling WORKS:
- Helper runs continuously in Session 1
- File I/O works across sessions
- No security restrictions on shared folder access
- Simple, reliable, no external dependencies

## Integration with Test Scripts

The app launch test (`Z:\scripts\script.ps1`) should be updated to use this method:

### Before (doesn't work remotely):
```powershell
Start-Process notepad.exe
Start-Process mspaint.exe
Start-Process calc.exe
```

### After (works remotely):
```powershell
# From host, call:
.\Invoke-RemoteGUIApp.ps1 -AppName notepad -Action Launch -Count 25
.\Invoke-RemoteGUIApp.ps1 -AppName mspaint -Action Launch -Count 25
.\Invoke-RemoteGUIApp.ps1 -AppName calc -Action Launch -Count 25

# Measure time...

# Cleanup:
.\Invoke-RemoteGUIApp.ps1 -AppName notepad -Action CloseAll
.\Invoke-RemoteGUIApp.ps1 -AppName mspaint -Action CloseAll
.\Invoke-RemoteGUIApp.ps1 -AppName calc -Action CloseAll
```

## Troubleshooting

### Helper not responding
- Check if helper is running on VM: `Get-Process powershell`
- Check trigger file permissions: `Get-Acl Z:\gui_trigger.txt`
- Restart helper from VM desktop

### Apps launch but no windows visible
- Verify helper is in Session 1: Check SessionId in Process Explorer
- Ensure VM has active desktop session (not locked/logged out)

### Permission errors
- Ensure Z: drive is accessible from both Session 0 and Session 1
- Check that admin user has write access to Z:\

## Performance Notes
- Helper checks for trigger every 500ms (low CPU impact)
- Each app launch has 200ms delay (prevents race conditions)
- File I/O overhead: ~50ms per request
- Suitable for test automation (not high-frequency launches)

## Security Considerations
- Helper runs with logged-in user permissions
- No privilege escalation
- File-based communication limited to Z: drive (controlled share)
- Consider locking down Z:\gui_*.txt file permissions if needed

## Future Enhancements
- Add support for launching with arguments
- Add support for verifying window visibility
- Add timeout/retry logic for hung processes
- Log all launch/close actions to CSV for audit trail
