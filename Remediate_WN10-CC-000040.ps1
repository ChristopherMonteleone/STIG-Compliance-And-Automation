<#
.SYNOPSIS
    This PowerShell script disables the Autoplay feature for all drives.

.NOTES
    Author       : Christopher Monteleone
    LinkedIn     : https://www.linkedin.com/in/christopher-monteleone/
    GitHub       : https://github.com/ChristopherMonteleone
    Date Created : 2026-02-17
    Last Modified: 2026-02-17
    Version      : 1.0
    CVEs         : N/A
    Plugin IDs   : N/A
    STIG-ID      : WN10-CC-000040

.TESTED ON
    Date(s) Tested : 2026-02-17
    Tested By      : Christopher Monteleone
    Systems Tested : Windows 10
    PowerShell Ver.: 5.1

.USAGE
    Run this script with administrative privileges to disable Autoplay.
    Example syntax:
    PS C:\> .\Remediate_WN10-CC-000040.ps1
#>

# Define the Registry Path and Value
# 255 (0xFF) disables Autoplay on all drive types (Unknown, Removable, Fixed, Network, CD-ROM, RAM)
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$RegName = "NoDriveTypeAutoRun"
$RequiredValue = 255

try {
    # Check if the Registry Key (path) exists
    if (-not (Test-Path $RegPath)) {
        Write-Host "[-] Registry path does not exist. Creating path..." -ForegroundColor Yellow
        New-Item -Path $RegPath -Force | Out-Null
        Write-Host "    Created: $RegPath"
    }

    # Get the current value
    $CurrentSetting = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue

    # Check compliance
    if ($null -eq $CurrentSetting -or $CurrentSetting.$RegName -ne $RequiredValue) {
        Write-Host "[-] Non-Compliant: Autoplay is NOT disabled for all drives." -ForegroundColor Red
        if ($CurrentSetting) {
            Write-Host "    Current Value: $($CurrentSetting.$RegName) (Expected: $RequiredValue)" -ForegroundColor Yellow
        }
        
        # Remediate: Set NoDriveTypeAutoRun to 255
        Write-Host "    Setting '$RegName' to '$RequiredValue'..."
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $RequiredValue -Type DWord
        
        # Restart Explorer to apply changes (optional, but often needed for shell extensions immediately)
        # We will just force a GP update here to be safe, though a reboot/logoff is usually required for this specific setting to fully take effect visually.
        Write-Host "    Forcing Group Policy update..."
        gpupdate /force
        
        # Verify the fix
        $Verify = Get-ItemProperty -Path $RegPath -Name $RegName
        if ($Verify.$RegName -eq $RequiredValue) {
            Write-Host "[+] Success: Autoplay has been disabled for all drives." -ForegroundColor Green
        } else {
            Write-Host "[!] Failure: Could not update registry key." -ForegroundColor Red
        }
    }
    else {
        Write-Host "[+] Compliant: Autoplay is already disabled for all drives." -ForegroundColor Green
    }
}
catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}
