<#
.SYNOPSIS
    This PowerShell script ensures that "Enforce password history" is set to at least 24 passwords remembered.

.NOTES
    Author       : Christopher Monteleone
    LinkedIn     : https://www.linkedin.com/in/christopher-monteleone/
    GitHub       : https://github.com/ChristopherMonteleone
    Date Created : 2026-02-17
    Last Modified: 2026-02-17
    Version      : 1.0
    CVEs         : N/A
    Plugin IDs   : N/A
    STIG-ID      : WN10-AC-000020

.TESTED ON
    Date(s) Tested : 2026-02-17
    Tested By      : Christopher Monteleone
    Systems Tested : Windows 10
    PowerShell Ver.: 5.1

.USAGE
    Run this script with administrative privileges to enforce password history policy.
    Example syntax:
    PS C:\> .\Remediate_WN10-AC-000020.ps1
#>

# Define the STIG requirement (24 passwords)
$PasswordHistoryRequirement = 24

try {
    # Get the current password policy using net accounts
    # We parse the output because "net accounts" is the most compatible way to check local policy without external modules.
    $NetAccounts = net accounts
    
    # Select the line containing "Length of password history maintained"
    $HistoryLine = $NetAccounts | Select-String "Length of password history maintained"
    
    if ($HistoryLine -match "(\d+|None)") {
        $CurrentValue = $matches[1]

        # "None" means 0, which is non-compliant.
        # If it's a number, check if it's less than 24.
        if ($CurrentValue -eq "None" -or [int]$CurrentValue -lt $PasswordHistoryRequirement) {
            Write-Host "[-] Non-Compliant: Password history is currently set to '$CurrentValue'." -ForegroundColor Red
            
            # Remediate: Set password history to 24
            Write-Host "    Setting password history to $PasswordHistoryRequirement..."
            net accounts /uniquepw:$PasswordHistoryRequirement | Out-Null
            
            # Verify the fix
            $VerifyAccounts = net accounts
            $VerifyLine = $VerifyAccounts | Select-String "Length of password history maintained"
            
            if ($VerifyLine -match "$PasswordHistoryRequirement") {
                Write-Host "[+] Success: Password history set to $PasswordHistoryRequirement passwords." -ForegroundColor Green
            } else {
                Write-Host "[!] Failure: Could not update password history." -ForegroundColor Red
            }
        }
        else {
            Write-Host "[+] Compliant: Password history is already set to $CurrentValue (Requirement: $PasswordHistoryRequirement+)." -ForegroundColor Green
        }
    }
    else {
        Write-Host "[!] Error: Could not parse 'net accounts' output." -ForegroundColor Red
    }
}
catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}
