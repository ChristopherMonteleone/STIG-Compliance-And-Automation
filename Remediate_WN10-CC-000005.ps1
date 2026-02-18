<#
.SYNOPSIS
    This PowerShell script ensures that camera access from the lock screen is disabled.

.NOTES
    Author       : Christopher Monteleone
    LinkedIn     : https://www.linkedin.com/in/christopher-monteleone/
    GitHub       : https://github.com/ChristopherMonteleone
    Date Created : 2026-02-17
    Last Modified: 2026-02-17
    Version      : 1.0
    CVEs         : N/A
    Plugin IDs   : N/A
    STIG-ID      : WN10-CC-000005

.TESTED ON
    Date(s) Tested : 2026-02-17
    Tested By      : Christopher Monteleone
    Systems Tested : Windows 10
    PowerShell Ver.: 5.1

.USAGE
    Run this script with administrative privileges to enforce the Lock Screen Camera policy.
    Example syntax:
    PS C:\> .\Remediate_WN10-CC-000005.ps1
#>

# Define the Registry Path and Value
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$RegName = "NoLockScreenCamera"
$RequiredValue = 1

try {
    # Check if the Registry Key exists; create if missing
    if (-not (Test-Path $RegPath)) {
        Write-Host "[-] Registry key does not exist. Creating path..." -ForegroundColor Yellow
        New-Item -Path $RegPath -Force | Out-Null
        Write-Host "    Created: $RegPath"
    }

    # Get the current value
    $CurrentSetting = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue

    # Check compliance: Value must exist and equal 1
    if ($null -eq $CurrentSetting -or $CurrentSetting.$RegName -ne $RequiredValue) {
        Write-Host "[-] Non-Compliant: Lock screen camera is NOT disabled." -ForegroundColor Red
        
        # Remediate: Set NoLockScreenCamera to 1
        Write-Host "    Setting '$RegName' to '$RequiredValue'..."
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $RequiredValue -Type DWord
        
        # Force Group Policy update (optional but good practice for policy keys)
        Write-Host "    Forcing Group Policy update..."
        gpupdate /force
        
        # Verify the fix
        $Verify = Get-ItemProperty -Path $RegPath -Name $RegName
        if ($Verify.$RegName -eq $RequiredValue) {
            Write-Host "[+] Success: Camera access from lock screen has been disabled." -ForegroundColor Green
        } else {
            Write-Host "[!] Failure: Could not update registry key." -ForegroundColor Red
        }
    }
    else {
        Write-Host "[+] Compliant: Camera access from lock screen is already disabled." -ForegroundColor Green
    }
}
catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}
