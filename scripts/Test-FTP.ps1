# Test-FTP.ps1
# FTP download performance test - runs directly in VM
# Downloads all files from DIGI Storage folder via FTP
# Measures download time and appends to CSV

param(
    [string]$ConfigName = "baseline",
    [int]$Iterations = 5,
    [int]$DelaySeconds = 5,
    [string]$FtpPath = "/Digi Cloud/Test/"
)

# FTP Configuration (from FileZilla saved config)
$ftpServer = "storage.rcs-rds.ro"
$ftpUser = "robinet_AT_rdslink.ro"
$encodedPass = "c21AcnRwYXNzRDEyIQ=="
$ftpPass = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPass))
$ftpUri = "ftp://$ftpServer$FtpPath"

$destBasePath = "$env:USERPROFILE\Desktop\FTP"

Write-Host "`n=== FTP Download Test ===" -ForegroundColor Cyan
Write-Host "Configuration: $ConfigName" -ForegroundColor Yellow
Write-Host "Iterations: $Iterations" -ForegroundColor Yellow
Write-Host "FTP Server: $ftpServer" -ForegroundColor Gray
Write-Host "FTP Path: $FtpPath" -ForegroundColor Gray
Write-Host "Delay between iterations: $DelaySeconds seconds`n" -ForegroundColor Gray

# Setup CSV path
$dataFolder = "Z:\data\$ConfigName"
$ftpCSV = "$dataFolder\ftp-download-$ConfigName.csv"

# Create folders if needed
if (!(Test-Path $dataFolder)) {
    New-Item -Path $dataFolder -ItemType Directory -Force | Out-Null
}

if (!(Test-Path $destBasePath)) {
    New-Item -Path $destBasePath -ItemType Directory -Force | Out-Null
}

# Create CSV header if needed
if (!(Test-Path $ftpCSV)) {
    "Iteration,Timestamp,FileSizeMB,DownloadTimeSeconds,SpeedMBps,Configuration" | Out-File $ftpCSV -Encoding UTF8
}

# ============================================================================
# RUN ITERATIONS
# ============================================================================

for ($iteration = 1; $iteration -le $Iterations; $iteration++) {
    Write-Host "`n=== ITERATION $iteration of $Iterations ===" -ForegroundColor Cyan
    $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    
    # Clean up destination folder
    if (Test-Path $destBasePath) {
        Remove-Item $destBasePath -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -Path $destBasePath -ItemType Directory -Force | Out-Null
    
    Write-Host "Connecting to FTP server..." -ForegroundColor Yellow
    
    try {
        # Function to recursively list and download files from FTP
        function Get-FtpFilesRecursive {
            param(
                [string]$FtpPath,
                [string]$LocalPath,
                [string]$Server,
                [System.Net.NetworkCredential]$Credentials
            )
            
            $fileList = @()
            
            # List directory contents
            $ftpUri = "ftp://$Server$FtpPath"
            $listRequest = [System.Net.FtpWebRequest]::Create($ftpUri)
            $listRequest.Credentials = $Credentials
            $listRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
            $listRequest.UsePassive = $true
            $listRequest.KeepAlive = $false
            
            try {
                $listResponse = $listRequest.GetResponse()
                $listStream = $listResponse.GetResponseStream()
                $listReader = New-Object System.IO.StreamReader($listStream)
                
                while (($line = $listReader.ReadLine()) -ne $null) {
                    $parts = $line -split '\s+'
                    $itemName = $parts[-1]
                    
                    if ($line -match '^d') {
                        # It's a directory - recurse into it
                        Write-Host "    Found folder: $itemName" -ForegroundColor Cyan
                        $subPath = $FtpPath.TrimEnd('/') + "/" + $itemName + "/"
                        $subLocalPath = Join-Path $LocalPath $itemName
                        
                        # Recursively get files from subdirectory
                        $fileList += Get-FtpFilesRecursive -FtpPath $subPath -LocalPath $subLocalPath -Server $Server -Credentials $Credentials
                        
                    } elseif ($line -match '^-') {
                        # It's a file
                        $fileList += @{
                            RemotePath = $FtpPath
                            FileName = $itemName
                            LocalPath = $LocalPath
                        }
                    }
                }
                
                $listReader.Close()
                $listStream.Close()
                $listResponse.Close()
                
            } catch {
                Write-Host "    Warning: Could not list $FtpPath : $_" -ForegroundColor Yellow
            }
            
            return $fileList
        }
        
        # Create credentials object
        $credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        
        # Get all files recursively
        Write-Host "Scanning FTP directory (including subfolders)..." -ForegroundColor Yellow
        $fileList = Get-FtpFilesRecursive -FtpPath $FtpPath -LocalPath $destBasePath -Server $ftpServer -Credentials $credentials
        
        if ($fileList.Count -eq 0) {
            Write-Host "  X No files found in $FtpPath" -ForegroundColor Red
            continue
        }
        
        Write-Host "  + Found $($fileList.Count) file(s) to download (including subfolders)" -ForegroundColor Green
        
        # Start timing
        $startTime = Get-Date
        $totalBytes = 0
        
        # Download each file
        foreach ($fileInfo in $fileList) {
            $fileUri = "ftp://$ftpServer$($fileInfo.RemotePath)$($fileInfo.FileName)"
            $localFolder = $fileInfo.LocalPath
            $localFile = Join-Path $localFolder $fileInfo.FileName
            
            # Create local folder if needed
            if (!(Test-Path $localFolder)) {
                New-Item -Path $localFolder -ItemType Directory -Force | Out-Null
            }
            
            Write-Host "  Downloading: $($fileInfo.RemotePath)$($fileInfo.FileName)" -ForegroundColor Gray
            
            # Get file size
            $sizeRequest = [System.Net.FtpWebRequest]::Create($fileUri)
            $sizeRequest.Credentials = $credentials
            $sizeRequest.Method = [System.Net.WebRequestMethods+Ftp]::GetFileSize
            $sizeRequest.UsePassive = $true
            $sizeRequest.KeepAlive = $false
            $sizeResponse = $sizeRequest.GetResponse()
            $fileSize = $sizeResponse.ContentLength
            $sizeResponse.Close()
            
            # Download file
            $request = [System.Net.FtpWebRequest]::Create($fileUri)
            $request.Credentials = $credentials
            $request.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
            $request.UseBinary = $true
            $request.UsePassive = $true
            $request.KeepAlive = $false
            
            $response = $request.GetResponse()
            $responseStream = $response.GetResponseStream()
            $fileStream = [System.IO.File]::Create($localFile)
            
            $buffer = New-Object byte[] 8192
            do {
                $bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)
                $fileStream.Write($buffer, 0, $bytesRead)
            } while ($bytesRead -gt 0)
            
            $fileStream.Close()
            $responseStream.Close()
            $response.Close()
            
            $totalBytes += $fileSize
        }
        
        $endTime = Get-Date
        
        # Calculate metrics with 2 decimal precision
        $fileSizeMB = "{0:F2}" -f ($totalBytes / 1MB)
        $downloadTimeSeconds = "{0:F2}" -f ($endTime - $startTime).TotalSeconds
        $speedMBps = "{0:F2}" -f ([double]$fileSizeMB / [double]$downloadTimeSeconds)
        
        Write-Host "  + Total Size: $fileSizeMB MB" -ForegroundColor Green
        Write-Host "  + Download Time: $downloadTimeSeconds seconds" -ForegroundColor Green
        Write-Host "  + Speed: $speedMBps MB/s" -ForegroundColor Green
        
        # Write to CSV
        "$iteration,$timestamp,$fileSizeMB,$downloadTimeSeconds,$speedMBps,$ConfigName" | Out-File $ftpCSV -Append -Encoding UTF8
        Write-Host "  + Data saved to CSV" -ForegroundColor Green
        
        # Cleanup
        Write-Host "Cleaning up..." -ForegroundColor Yellow
        Remove-Item $destBasePath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  + Cleanup complete" -ForegroundColor Green
        
        # Delay before next iteration (except after last one)
        if ($iteration -lt $Iterations) {
            Write-Host "`nWaiting $DelaySeconds seconds before next iteration..." -ForegroundColor Yellow
            Start-Sleep -Seconds $DelaySeconds
        }
        
    } catch {
        Write-Host "`nX Error during iteration $iteration : $_" -ForegroundColor Red
        
        # Try cleanup even on error
        Remove-Item $destBasePath -Recurse -Force -ErrorAction SilentlyContinue
        
        # If first iteration fails, exit with helpful message
        if ($iteration -eq 1) {
            Write-Host "`nFTP connection failed. Check:" -ForegroundColor Red
            Write-Host "  • Internet connection is working" -ForegroundColor Yellow
            Write-Host "  • FTP credentials are still valid" -ForegroundColor Yellow
            Write-Host "  • Files exist in $FtpPath" -ForegroundColor Yellow
            Write-Host "  • Firewall allows FTP access" -ForegroundColor Yellow
            exit 1
        }
    }
}

Write-Host "`n=== All Iterations Complete ===" -ForegroundColor Green
Write-Host "Results saved to: $ftpCSV`n" -ForegroundColor Gray

