@echo off
REM Run-All-Configurations.bat
REM Master batch file to run full testing pipeline for all 4 configurations
REM Total estimated time: ~100 minutes (25 min per configuration)

setlocal enabledelayedexpansion

echo.
echo ===============================================================================
echo    FULL TESTING PIPELINE - ALL CONFIGURATIONS
echo ===============================================================================
echo.
echo This will run complete testing (5 iterations each test) for:
echo   1. Baseline     (no security software)
echo   2. Antivirus    (Symantec Endpoint Protection only)
echo   3. Firewall     (Windows Firewall only)
echo   4. Both         (Antivirus + Firewall)
echo.
echo Total Tests: 100 iterations (25 per configuration)
echo Estimated Time: ~100 minutes (25 min per configuration)
echo.
echo IMPORTANT: 
echo   - VM must be running before starting
echo   - Ensure NAS and FTP server are accessible
echo   - Do not interrupt tests in progress
echo.

pause

set SCRIPT_DIR=%~dp0
set START_TIME=%TIME%
set FAILED=0
set SUCCESS=0

echo.
echo ===============================================================================
echo Pipeline started at: %DATE% %TIME%
echo ===============================================================================
echo.

REM Configuration 1: Baseline
echo.
echo ===============================================================================
echo [1/4] BASELINE CONFIGURATION
echo ===============================================================================
echo.
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Run-Baseline-Full-Pipeline.ps1"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [BASELINE] SUCCESS
    set /a SUCCESS+=1
) else (
    echo.
    echo [BASELINE] FAILED
    set /a FAILED+=1
)

REM Configuration 2: Antivirus
echo.
echo ===============================================================================
echo [2/4] ANTIVIRUS CONFIGURATION
echo ===============================================================================
echo.
echo MANUAL STEP REQUIRED:
echo   1. Install Symantec Endpoint Protection on VM
echo   2. Ensure it is running
echo   3. Press Enter when ready to continue...
echo.
pause

powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Run-Antivirus-Full-Pipeline.ps1"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [ANTIVIRUS] SUCCESS
    set /a SUCCESS+=1
) else (
    echo.
    echo [ANTIVIRUS] FAILED
    set /a FAILED+=1
)

REM Configuration 3: Firewall
echo.
echo ===============================================================================
echo [3/4] FIREWALL CONFIGURATION
echo ===============================================================================
echo.
echo MANUAL STEP REQUIRED:
echo   1. Uninstall Symantec from VM
echo   2. Enable Windows Firewall
echo   3. Press Enter when ready to continue...
echo.
pause

powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Run-Firewall-Full-Pipeline.ps1"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [FIREWALL] SUCCESS
    set /a SUCCESS+=1
) else (
    echo.
    echo [FIREWALL] FAILED
    set /a FAILED+=1
)

REM Configuration 4: Both
echo.
echo ===============================================================================
echo [4/4] BOTH (ANTIVIRUS + FIREWALL) CONFIGURATION
echo ===============================================================================
echo.
echo MANUAL STEP REQUIRED:
echo   1. Re-install Symantec on VM
echo   2. Ensure Windows Firewall is still enabled
echo   3. Press Enter when ready to continue...
echo.
pause

powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Run-Both-Full-Pipeline.ps1"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [BOTH] SUCCESS
    set /a SUCCESS+=1
) else (
    echo.
    echo [BOTH] FAILED
    set /a FAILED+=1
)

set END_TIME=%TIME%

echo.
echo ===============================================================================
echo    ALL CONFIGURATIONS COMPLETE
echo ===============================================================================
echo.
echo Started:  %START_TIME%
echo Finished: %END_TIME%
echo.
echo Results:
echo   Success: %SUCCESS% / 4
echo   Failed:  %FAILED% / 4
echo.
echo Data Location: C:\VMShare\data\
echo   - baseline\
echo   - antivirus\
echo   - firewall\
echo   - both\
echo.

if %FAILED% EQU 0 (
    echo ===============================================================================
    echo    ALL TESTS PASSED - READY FOR ANALYSIS
    echo ===============================================================================
) else (
    echo ===============================================================================
    echo    SOME TESTS FAILED - REVIEW LOGS ABOVE
    echo ===============================================================================
)

echo.
pause
