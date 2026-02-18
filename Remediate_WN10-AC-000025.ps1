<#
.SYNOPSIS
    This PowerShell script ensures that the maximum password age is configured to 60 days or less.

.NOTES
    Author       : Christopher Monteleone
    LinkedIn     : https://www.linkedin.com/in/christopher-monteleone/
    GitHub       : https://github.com/ChristopherMonteleone
    Date Created : 2026-02-17
    Last Modified: 2026-02-17
    Version      : 1.0
    CVEs         : N/A
    Plugin IDs   : N/A
    STIG-ID      : WN10-AC-000025

.TESTED ON
    Date(s) Tested : 2026-02-17
    Tested By      : Christopher Monteleone
    Systems Tested : Windows 10
    PowerShell Ver.: 5.1

.USAGE
    Run this script with administrative privileges to enforce the maximum password age policy.
    Example syntax:
    PS C:\> .\Remediate_WN10-AC-000025.ps1
#>

# Define the STIG requirement (60 days)
$MaxPasswordAgeRequirement = 60

try {
    # Get the current password policy using net accounts
    # Parsing text output because there is no native "Get-LocalPasswordPolicy" cmdlet in basic PS 5.1
    $NetAccounts = net accounts
    $MaxAgeLine = $NetAccounts | Select-String "Maximum password age"
    
    if ($MaxAgeLine -match "(\d+|Unlimited)") {
        $CurrentValue = $matches[1]

        # Handle "Unlimited" or values greater than the requirement
        if ($CurrentValue -eq "Unlimited" -or [int]$CurrentValue -gt $MaxPasswordAgeRequirement) {
            Write-Host "[-] Non-Compliant: Maximum password age is currently '$CurrentValue'." -ForegroundColor Red
            
            # Remediate: Set max password age to 60 days
            Write-Host "    Setting maximum password age to $MaxPasswordAgeRequirement days..."
            net accounts /maxpwage:$MaxPasswordAgeRequirement | Out-Null
            
            # Verify the fix
            $VerifyAccounts = net accounts
            $VerifyLine = $VerifyAccounts | Select-String "Maximum password age"
            if ($VerifyLine -match "$MaxPasswordAgeRequirement") {
                Write-Host "[+] Success: Maximum password age set to $MaxPasswordAgeRequirement days." -ForegroundColor Green
            } else {
                Write-Host "[!] Failure: Could not update maximum password age." -ForegroundColor Red
            }
        }
        else {
            Write-Host "[+] Compliant: Maximum password age is already set to $CurrentValue days (Limit: $MaxPasswordAgeRequirement)." -ForegroundColor Green
        }
    }
    else {
        Write-Host "[!] Error: Could not parse 'net accounts' output." -ForegroundColor Red
    }
}
catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}
