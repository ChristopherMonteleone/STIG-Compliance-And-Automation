<#
.SYNOPSIS
    This PowerShell script ensures that the Windows Defender Firewall is enabled for all network profiles (Domain, Private, and Public).

.NOTES
    Author       : Christopher Monteleone
    LinkedIn     : https://www.linkedin.com/in/christopher-monteleone/
    GitHub       : https://github.com/ChristopherMonteleone
    Date Created : 2026-02-17
    Last Modified: 2026-02-17
    Version      : 1.0
    CVEs         : N/A
    Plugin IDs   : N/A
    STIG-ID      : WN10-00-000135

.TESTED ON
    Date(s) Tested : 2026-02-17
    Tested By      : Christopher Monteleone
    Systems Tested : Windows 10
    PowerShell Ver.: 5.1

.USAGE
    Run this script with administrative privileges to enable the Windows Firewall.
    Example syntax:
    PS C:\> .\Remediate_WN10-00-000135.ps1
#>

try {
    # Get the current status of all Firewall profiles (Domain, Private, Public)
    $Profiles = Get-NetFirewallProfile -ErrorAction Stop
    $NonCompliant = $Profiles | Where-Object { $_.Enabled -eq $False }

    if ($NonCompliant) {
        Write-Host "[-] Non-Compliant: One or more Firewall profiles are DISABLED." -ForegroundColor Red
        Write-Host "    Found issues in: $($NonCompliant.Name -join ', ')" -ForegroundColor Yellow
        
        # Remediate by enabling all profiles
        Write-Host "    Enabling Windows Defender Firewall for all profiles..."
        Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
        
        # Verify the fix
        $Verify = Get-NetFirewallProfile
        if (($Verify | Where-Object { $_.Enabled -eq $False }).Count -eq 0) {
            Write-Host "[+] Success: All Firewall profiles are now ENABLED." -ForegroundColor Green
        } else {
            Write-Host "[!] Failure: Could not enable all Firewall profiles." -ForegroundColor Red
        }
    }
    else {
        Write-Host "[+] Compliant: Windows Defender Firewall is already enabled for all profiles." -ForegroundColor Green
    }
}
catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}
