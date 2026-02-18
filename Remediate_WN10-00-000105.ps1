<#
.SYNOPSIS
    This PowerShell script ensures that the Simple Network Management Protocol (SNMP) is not installed on the system.

.NOTES
    Author       : Christopher Monteleone
    LinkedIn     : https://www.linkedin.com/in/christopher-monteleone/
    GitHub       : https://github.com/ChristopherMonteleone
    Date Created : 2026-02-17
    Last Modified: 2026-02-17
    Version      : 1.0
    CVEs         : N/A
    Plugin IDs   : N/A
    STIG-ID      : WN10-00-000105

.TESTED ON
    Date(s) Tested : 2026-02-17
    Tested By      : Christopher Monteleone
    Systems Tested : Windows 10
    PowerShell Ver.: 5.1

.USAGE
    Run this script with administrative privileges to disable the SNMP Windows feature.
    Example syntax:
    PS C:\> .\Remediate_WN10-00-000105.ps1
#>

# Define the specific Windows Feature for SNMP
$FeatureName = "SNMP"

try {
    # Check the current state of the feature
    $Feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName -ErrorAction Stop

    if ($Feature.State -eq 'Enabled') {
        Write-Host "[-] Non-Compliant: $FeatureName is currently ENABLED. Starting remediation..." -ForegroundColor Red
        
        # Remediate by disabling the feature
        Disable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart | Out-Null
        
        # Verify the fix
        $Verify = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName
        if ($Verify.State -eq 'Disabled') {
            Write-Host "[+] Success: $FeatureName has been disabled." -ForegroundColor Green
        } else {
            Write-Host "[!] Failure: Could not disable $FeatureName." -ForegroundColor Red
        }
    }
    else {
        Write-Host "[+] Compliant: $FeatureName is already disabled." -ForegroundColor Green
    }
}
catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}
