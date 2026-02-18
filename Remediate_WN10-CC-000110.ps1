<#
.SYNOPSIS
    This PowerShell script ensures that printing over HTTP is disabled on the system.

.NOTES
    Author       : Christopher Monteleone
    LinkedIn     : https://www.linkedin.com/in/christopher-monteleone/
    GitHub       : https://github.com/ChristopherMonteleone
    Date Created : 2026-02-17
    Last Modified: 2026-02-17
    Version      : 1.0
    CVEs         : N/A
    Plugin IDs   : N/A
    STIG-ID      : WN10-CC-000110

.TESTED ON
    Date(s) Tested : 2026-02-17
    Tested By      : Christopher Monteleone
    Systems Tested : Windows 10
    PowerShell Ver.: 5.1

.USAGE
    Run this script with administrative privileges to disable HTTP printing.
    Example syntax:
    PS C:\> .\Remediate_WN10-CC-000110.ps1
#>

# Define the Registry Path and Value
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
$RegName = "DisableHTTPPrinting"
$RequiredValue = 1

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
        Write-Host "[-] Non-Compliant: HTTP Printing is NOT disabled." -ForegroundColor Red
        if ($CurrentSetting) {
            Write-Host "    Current Value: $($CurrentSetting.$RegName) (Expected: $RequiredValue)" -ForegroundColor Yellow
        }
        
        # Remediate: Set DisableHTTPPrinting to 1
        Write-Host "    Setting '$RegName' to '$RequiredValue'..."
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $RequiredValue -Type DWord
        
        # Force Group Policy update
        Write-Host "    Forcing Group Policy update..."
        gpupdate /force
        
        # Verify the fix
        $Verify = Get-ItemProperty -Path $RegPath -Name $RegName
        if ($Verify.$RegName -eq $RequiredValue) {
            Write-Host "[+] Success: HTTP Printing has been disabled." -ForegroundColor Green
        } else {
            Write-Host "[!] Failure: Could not update registry key." -ForegroundColor Red
        }
    }
    else {
        Write-Host "[+] Compliant: HTTP Printing is already disabled." -ForegroundColor Green
    }
}
catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}
